import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

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

  /// Fires on every write/delete of the access token — sign-in, refresh,
  /// logout.
  Stream<void> watchAccessToken() => box.watch(key: AppKeys.accessToken);

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

  /// This installation's terminal id — a UUID v4 generated on first call
  /// and kept for good. It lives in this box (not the app folder), so a
  /// self-update, which replaces the app folder, keeps it; and it is not in
  /// [clearSession]'s key list, so a logout or another cashier signing in
  /// keeps it too. One id = one bar PC, whoever is signed in on it.
  String getTerminalId() {
    final stored = box.get(AppKeys.terminalId);
    if (stored is String && stored.isNotEmpty) return stored;
    final generated = const Uuid().v4();
    // Not awaited: Hive updates its in-memory copy synchronously, so the
    // next read already sees the id even before the disk write lands.
    box.put(AppKeys.terminalId, generated);
    return generated;
  }

  /// Raw map written by `UpdateFailureLog`; the log owns its schema.
  Map<String, dynamic>? getLastUpdateFailure() {
    final raw = box.get(AppKeys.lastUpdateFailure);
    return raw is Map ? Map<String, dynamic>.from(raw) : null;
  }

  Future<void> setLastUpdateFailure(Map<String, dynamic>? value) async {
    if (value == null) return box.delete(AppKeys.lastUpdateFailure);
    await box.put(AppKeys.lastUpdateFailure, value);
  }
}
