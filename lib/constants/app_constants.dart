/// Backend base URL. Set per build via
/// `flutter run --dart-define=API_BASE_URL=https://api.pixelpark.uz/api`;
/// defaults to the shared test API so a plain `flutter run` works out of
/// the box during development. CI builds `main` against production and
/// every other ref against test.
abstract final class AppConstants {
  static const String defaultApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://test.api.pixelpark.uz/api',
  );

  /// Minimum window size — below this the product grid + cart panel layout
  /// no longer fits (same floor as the park cashier app).
  static const double minWindowWidth = 800;
  static const double minWindowHeight = 600;
}
