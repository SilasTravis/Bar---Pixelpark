/// Hive box keys — one flat box, matching the cashier app's `LocalSource`.
abstract final class AppKeys {
  static const String accessToken = 'accessToken';
  static const String refreshToken = 'refreshToken';

  static const String cashierId = 'cashierId';
  static const String cashierFullName = 'cashierFullName';
  static const String cashierUsername = 'cashierUsername';
  static const String barId = 'barId';
  static const String barName = 'barName';

  static const String languageCode = 'languageCode';

  /// The receipt printer the cashier picked in Settings. Absent = no
  /// printing at all (printing is optional for a bar). Device config, not
  /// session: never cleared on logout.
  static const String receiptPrinterName = 'receiptPrinterName';
}
