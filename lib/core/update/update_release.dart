/// Matches a lowercase-normalized SHA-256 hex digest: 64 hex characters.
final RegExp _sha256Pattern = RegExp(r'^[0-9a-f]{64}$');

/// Parses the raw text of a `.sha256` release asset into a lowercase hex
/// digest. Accepts a bare digest or the `<digest>  <filename>` form produced
/// by `sha256sum`, trims surrounding whitespace, and normalizes case.
///
/// Returns null when [raw] is null, empty, or doesn't reduce to a valid
/// 64-character hex digest — e.g. an HTML error page served for a 404.
String? parseSha256Digest(String? raw) {
  final trimmed = raw?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  // The file may be a bare digest or `<digest>  <filename>`.
  final token = trimmed.split(RegExp(r'\s+')).first.toLowerCase();
  return _sha256Pattern.hasMatch(token) ? token : null;
}

/// One published release, reduced to what the updater needs.
class UpdateRelease {
  const UpdateRelease({
    required this.version,
    required this.notes,
    required this.zipUrl,
    required this.zipSize,
    required this.sha256Url,
    required this.releasePageUrl,
    this.sha256,
  });

  /// Release tag with any leading `v` stripped, e.g. `1.2.3`.
  final String version;
  final String notes;
  final String zipUrl;
  final int zipSize;

  /// Null when CI didn't attach a digest — the download then skips
  /// verification rather than refusing to update.
  final String? sha256Url;
  final String releasePageUrl;

  /// The digest itself, for sources that return it inline with the release
  /// (the Pixel Park backend mirror) instead of as a separate asset.
  final String? sha256;

  /// Prefix of the Windows package CI publishes:
  /// `bar_app-windows-v<version>.zip` (+ `.sha256`).
  static const String windowsZipPrefix = 'bar_app-windows-';

  /// Parses `GET /repos/{owner}/{repo}/releases/latest`. Returns null when
  /// the payload has no tag or no Windows `.zip` asset, which is what a
  /// release published by hand (or by a half-finished CI run) looks like.
  ///
  /// Only the Windows zip is ever picked: a release may also carry a macOS
  /// build, and installing that over a Windows till would brick it.
  static UpdateRelease? fromGithubJson(Map<String, dynamic> json) {
    final tag = json['tag_name'] as String?;
    if (tag == null || tag.isEmpty) return null;

    final assets = (json['assets'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList();
    final zip = _windowsZip(assets);
    if (zip == null) return null;

    final zipUrl = zip['browser_download_url'];
    if (zipUrl is! String) return null;
    final zipName = zip['name'] as String;

    return UpdateRelease(
      version: tag.startsWith('v') ? tag.substring(1) : tag,
      notes: (json['body'] as String?) ?? '',
      zipUrl: zipUrl,
      zipSize: (zip['size'] as num?)?.toInt() ?? 0,
      sha256Url:
          _assetNamed(assets, '$zipName.sha256')?['browser_download_url']
              as String?,
      releasePageUrl: (json['html_url'] as String?) ?? '',
    );
  }

  static Map<String, dynamic>? _windowsZip(List<Map<String, dynamic>> assets) {
    for (final asset in assets) {
      final name = asset['name'] as String?;
      if (name != null &&
          name.startsWith(windowsZipPrefix) &&
          name.endsWith('.zip')) {
        return asset;
      }
    }
    return null;
  }

  static Map<String, dynamic>? _assetNamed(
    List<Map<String, dynamic>> assets,
    String name,
  ) {
    for (final asset in assets) {
      if (asset['name'] == name) return asset;
    }
    return null;
  }
}

/// Parses `GET /v1/bar/app-update/latest` from the Pixel Park backend, which
/// mirrors the GitHub releases for networks that block github.com. Returns
/// null when the mirror holds no release yet or the payload is malformed.
/// [downloadBaseUrl] is the API origin the zip is served from.
UpdateRelease? updateReleaseFromBackendJson(
  Map<String, dynamic> json, {
  required String downloadBaseUrl,
}) {
  final latest = json['latest'];
  if (latest is! Map<String, dynamic>) return null;
  final version = latest['version'];
  if (version is! String || version.isEmpty) return null;
  final base = downloadBaseUrl.replaceAll(RegExp(r'/+$'), '');
  return UpdateRelease(
    version: version,
    notes: (latest['notes'] as String?) ?? '',
    zipUrl: '$base/v1/bar/app-update/${Uri.encodeComponent(version)}/download',
    zipSize: (latest['zipSize'] as num?)?.toInt() ?? 0,
    sha256Url: null,
    sha256: latest['sha256'] as String?,
    // github.com may be exactly what's blocked here — no page worth linking.
    releasePageUrl: '',
  );
}
