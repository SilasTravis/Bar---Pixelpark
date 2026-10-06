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

/// Reads releases from the public GitHub API — the bar app's ONLY release
/// source in v1 (the park cashier also has a backend mirror; the bar has
/// none yet, see the bar design spec's "Updates" decision).
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
  }) async {
    await _dio.download(
      release.zipUrl,
      savePath,
      options: Options(
        connectTimeout: _connectTimeout,
        receiveTimeout: _downloadStallTimeout,
      ),
      onReceiveProgress: (received, total) {
        // GitHub sends Content-Length, but fall back to the asset size from
        // the API when a proxy strips it, so the progress bar stays useful.
        onProgress?.call(received, total > 0 ? total : release.zipSize);
      },
    );
  }
}
