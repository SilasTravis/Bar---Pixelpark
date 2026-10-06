import 'package:hive_ce/hive.dart';

import 'app_keys.dart';

/// Session + device-config persistence — tokens, the signed-in bar cashier
/// and its bar. [clearSession] wipes the session part on logout; device
/// settings (language, printer) survive it.
class LocalSource {
  LocalSource(this.box);

  final Box<dynamic> box;

  static const String boxName = 'bar_app_box';

  Future<void> clearSession() async {
    await box.deleteAll([
      AppKeys.accessToken,
      AppKeys.refreshToken,
      AppKeys.cashierId,
      AppKeys.cashierFullName,
      AppKeys.cashierUsername,
      AppKeys.barId,
      AppKeys.barName,
    ]);
  }

  bool get hasSession => getAccessToken() != null;

  void setAccessToken(String? value) {
    if (value == null) return;
    box.put(AppKeys.accessToken, value);
  }

  String? getAccessToken() => box.get(AppKeys.accessToken) as String?;

  void setRefreshToken(String? value) {
    if (value == null) return;
    box.put(AppKeys.refreshToken, value);
  }

  String? getRefreshToken() => box.get(AppKeys.refreshToken) as String?;

  void setCashier({
    required String id,
    required String fullName,
    required String username,
    required String barId,
    required String barName,
  }) {
    box.putAll({
      AppKeys.cashierId: id,
      AppKeys.cashierFullName: fullName,
      AppKeys.cashierUsername: username,
      AppKeys.barId: barId,
      AppKeys.barName: barName,
    });
  }

  String? getCashierId() => box.get(AppKeys.cashierId) as String?;
  String? getCashierFullName() => box.get(AppKeys.cashierFullName) as String?;
  String? getCashierUsername() => box.get(AppKeys.cashierUsername) as String?;
  String? getBarId() => box.get(AppKeys.barId) as String?;
  String? getBarName() => box.get(AppKeys.barName) as String?;

  Future<void> setLanguageCode(String value) async {
    await box.put(AppKeys.languageCode, value);
  }

  String getLanguageCode() =>
      box.get(AppKeys.languageCode, defaultValue: 'uz') as String;

  Future<void> setReceiptPrinterName(String? value) async {
    if (value == null) return box.delete(AppKeys.receiptPrinterName);
    await box.put(AppKeys.receiptPrinterName, value);
  }

  String? getReceiptPrinterName() =>
      box.get(AppKeys.receiptPrinterName) as String?;
}
