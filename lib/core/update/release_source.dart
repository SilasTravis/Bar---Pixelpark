import 'package:dio/dio.dart';

import 'update_exception.dart';
import 'update_release.dart';

/// Where update packages come from. An interface so [UpdateService] can be
/// tested against a fake without touching the network.
abstract interface class ReleaseSource {
  Future<UpdateRelease?> fetchLatest();

  /// The published SHA-256 digest as lowercase hex, or null when the release
  /// has no digest asset.
  Future<String?> fetchSha256(UpdateRelease release);

  Future<void> downloadZip(
    UpdateRelease release,
    String savePath, {
    void Function(int received, int total)? onProgress,
  });
}

/// Reads releases from the public GitHub API — the fallback behind the
/// backend mirror ([BackendReleaseSource]) for a backend that predates it.
///
/// The repo is public, so every request here is unauthenticated — this must
/// never carry a token, and it deliberately uses its own [Dio] rather than
/// the app's API client, whose base URL and bearer interceptor point at the
/// Pixel Park backend.
///
/// [repoSlug] must stay the bar's own repo. Never point it at the cashier
/// release repo: cashier terminals would then install the bar build (and
/// vice versa).
class GithubReleaseSource implements ReleaseSource {
  GithubReleaseSource({Dio? dio}) : _dio = dio ?? Dio();

  static const String repoSlug = 'SilasTravis/Bar---Pixelpark';
  static const String latestReleaseUrl =
      'https://api.github.com/repos/$repoSlug/releases/latest';

  /// Time to establish the TCP/TLS connection, on every call this class
  /// makes. On a captive portal or a black-holed connection this is what
  /// stops `UpdateChecking`/`UpdateDownloading` from spinning forever.
  static const Duration _connectTimeout = Duration(seconds: 10);

  /// Ceiling for the two small JSON/text calls: the whole response is a few
  /// KB, so if it hasn't arrived in this long the connection is stalled.
  static const Duration _metadataReceiveTimeout = Duration(seconds: 15);

  /// Ceiling for the zip download, applied between received chunks (not to
  /// the whole transfer), so only a download that goes silent trips it.
  static const Duration _downloadStallTimeout = Duration(seconds: 30);

  final Dio _dio;

  @override
  Future<UpdateRelease?> fetchLatest() async {
    final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.get<Map<String, dynamic>>(
        latestReleaseUrl,
        options: Options(
          headers: const {'Accept': 'application/vnd.github+json'},
          connectTimeout: _connectTimeout,
          receiveTimeout: _metadataReceiveTimeout,
        ),
      );
    } on DioException catch (e) {
      // A repo with no releases at all returns 404 from this endpoint —
      // that's "nothing to update to", not a failure. Only treat it that
      // way when the server actually answered with a 404: a connection
      // failure carries no response at all and must still surface.
      if (e.type == DioExceptionType.badResponse &&
          e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
    final data = response.data;
    if (data == null) return null;
    return UpdateRelease.fromGithubJson(data);
  }

  @override
  Future<String?> fetchSha256(UpdateRelease release) async {
    final url = release.sha256Url;
    // No .sha256 asset was published for this release at all — verification
    // is legitimately skipped, not a failure.
    if (url == null) return null;

    final response = await _dio.get<String>(
      url,
      options: Options(
        responseType: ResponseType.plain,
        connectTimeout: _connectTimeout,
        receiveTimeout: _metadataReceiveTimeout,
      ),
    );
    final digest = parseSha256Digest(response.data);
    if (digest == null) {
      // The asset exists but its body isn't a valid digest. Fail closed so
      // an unverified binary is never installed.
      throw UpdateException(
        'Could not read the published checksum for version '
        '${release.version} at $url — the file did not contain a valid '
        'SHA-256 digest. Refusing to install an unverified update.',
        UpdateFailureCode.checksumUnreadable,
      );
    }
    return digest;
  }

  @override
  Future<void> downloadZip(
    UpdateRelease release,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) => _downloadReleaseZip(_dio, release, savePath, onProgress: onProgress);
}

/// Streams [release]'s zip to [savePath] with the shared timeouts. [dio]
/// must carry no base URL or auth: the zip URL is absolute and public.
Future<void> _downloadReleaseZip(
  Dio dio,
  UpdateRelease release,
  String savePath, {
  void Function(int received, int total)? onProgress,
}) async {
  await dio.download(
    release.zipUrl,
    savePath,
    options: Options(
      connectTimeout: GithubReleaseSource._connectTimeout,
      receiveTimeout: GithubReleaseSource._downloadStallTimeout,
    ),
    onReceiveProgress: (received, total) {
      // The server sends Content-Length, but fall back to the size from the
      // release metadata when a proxy strips it, so the progress bar stays
      // useful.
      onProgress?.call(received, total > 0 ? total : release.zipSize);
    },
  );
}

/// Reads releases from the Pixel Park backend's mirror of the GitHub
/// releases (`/v1/bar/app-update/*`) — some bar networks block github.com,
/// but always reach our own API.
///
/// The `latest` check goes through the app's [Dio] ([_api]): it needs the
/// bar cashier token and gets its refresh-on-401 for free. The zip itself is
/// public and fetched with a separate plain client ([_download]), so the app
/// client's retry interceptor never re-issues a half-finished download.
class BackendReleaseSource implements ReleaseSource {
  BackendReleaseSource({
    required this._api,
    required this._hasSession,
    Dio? download,
  }) : _download = download ?? Dio();

  static const String latestPath = '/v1/bar/app-update/latest';

  final Dio _api;
  final Dio _download;

  /// Whether a bar cashier is signed in. Without a token `latest` would 401,
  /// and the app client's refresh-on-401 ends the session — resetting the
  /// login screen under a cashier who is typing into it.
  final bool Function() _hasSession;

  @override
  Future<UpdateRelease?> fetchLatest() async {
    if (!_hasSession()) {
      throw StateError('No bar session - update mirror needs a token');
    }
    final response = await _api.get<Map<String, dynamic>>(
      latestPath,
      options: Options(
        connectTimeout: GithubReleaseSource._connectTimeout,
        receiveTimeout: GithubReleaseSource._metadataReceiveTimeout,
      ),
    );
    final data = response.data;
    if (data == null) return null;
    return updateReleaseFromBackendJson(
      data,
      downloadBaseUrl: _api.options.baseUrl,
    );
  }

  @override
  Future<String?> fetchSha256(UpdateRelease release) async {
    final digest = parseSha256Digest(release.sha256);
    // The mirror always stores a digest, so a missing one means a broken
    // payload — fail closed instead of installing unverified.
    if (digest == null) {
      throw UpdateException(
        'The update server sent no valid checksum for version '
        '${release.version}. Refusing to install an unverified update.',
        UpdateFailureCode.checksumUnreadable,
      );
    }
    return digest;
  }

  @override
  Future<void> downloadZip(
    UpdateRelease release,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) =>
      _downloadReleaseZip(_download, release, savePath, onProgress: onProgress);
}

/// Tries [primary] first and falls back to [fallback] only when [primary]
/// fails outright (an older backend without the mirror answers 404, the API
/// is unreachable, or no one is signed in). When both fail, the primary's
/// error is rethrown. A release found by one source is always downloaded
/// and verified through that same source.
class FallbackReleaseSource implements ReleaseSource {
  FallbackReleaseSource({required this.primary, required this.fallback});

  final ReleaseSource primary;
  final ReleaseSource fallback;

  final Expando<ReleaseSource> _origin = Expando('release origin');

  @override
  Future<UpdateRelease?> fetchLatest() async {
    UpdateRelease? release;
    ReleaseSource source = primary;
    try {
      release = await primary.fetchLatest();
    } catch (primaryError, primaryStack) {
      source = fallback;
      try {
        release = await fallback.fetchLatest();
      } catch (_) {
        // Where the fallback (github.com) is blocked, its error says nothing
        // useful — the primary's is the one worth showing.
        Error.throwWithStackTrace(primaryError, primaryStack);
      }
    }
    if (release != null) _origin[release] = source;
    return release;
  }

  ReleaseSource _sourceOf(UpdateRelease release) => _origin[release] ?? primary;

  @override
  Future<String?> fetchSha256(UpdateRelease release) =>
      _sourceOf(release).fetchSha256(release);

  @override
  Future<void> downloadZip(
    UpdateRelease release,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) =>
      _sourceOf(release).downloadZip(release, savePath, onProgress: onProgress);
}
