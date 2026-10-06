// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class AppLocalization {
  AppLocalization();

  static AppLocalization? _current;

  static AppLocalization get current {
    assert(
      _current != null,
      'No instance of AppLocalization was loaded. Try to initialize the AppLocalization delegate before accessing AppLocalization.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<AppLocalization> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = AppLocalization();
      AppLocalization._current = instance;

      return instance;
    });
  }

  static AppLocalization of(BuildContext context) {
    final instance = AppLocalization.maybeOf(context);
    assert(
      instance != null,
      'No instance of AppLocalization present in the widget tree. Did you add AppLocalization.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static AppLocalization? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  /// `Pixel Bar`
  String get appTitle {
    return Intl.message('Pixel Bar', name: 'appTitle', desc: '', args: []);
  }

  /// `Bar kassasiga kirish uchun login va parolni kiriting`
  String get loginSubtitle {
    return Intl.message(
      'Bar kassasiga kirish uchun login va parolni kiriting',
      name: 'loginSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginUsername {
    return Intl.message('Login', name: 'loginUsername', desc: '', args: []);
  }

  /// `Parol`
  String get loginPassword {
    return Intl.message('Parol', name: 'loginPassword', desc: '', args: []);
  }

  /// `Parolni ko‘rsatish`
  String get loginShowPassword {
    return Intl.message(
      'Parolni ko‘rsatish',
      name: 'loginShowPassword',
      desc: '',
      args: [],
    );
  }

  /// `Kirish`
  String get loginButton {
    return Intl.message('Kirish', name: 'loginButton', desc: '', args: []);
  }

  /// `Login yoki parol noto‘g‘ri`
  String get loginInvalid {
    return Intl.message(
      'Login yoki parol noto‘g‘ri',
      name: 'loginInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Til`
  String get language {
    return Intl.message('Til', name: 'language', desc: '', args: []);
  }

  /// `O‘zbekcha`
  String get languageUzbek {
    return Intl.message('O‘zbekcha', name: 'languageUzbek', desc: '', args: []);
  }

  /// `Русский`
  String get languageRussian {
    return Intl.message('Русский', name: 'languageRussian', desc: '', args: []);
  }

  /// `Menyu`
  String get menu {
    return Intl.message('Menyu', name: 'menu', desc: '', args: []);
  }

  /// `Smena tarixi`
  String get menuHistory {
    return Intl.message(
      'Smena tarixi',
      name: 'menuHistory',
      desc: '',
      args: [],
    );
  }

  /// `Smenani yopish`
  String get menuCloseShift {
    return Intl.message(
      'Smenani yopish',
      name: 'menuCloseShift',
      desc: '',
      args: [],
    );
  }

  /// `Sozlamalar`
  String get menuSettings {
    return Intl.message('Sozlamalar', name: 'menuSettings', desc: '', args: []);
  }

  /// `Chiqish`
  String get logout {
    return Intl.message('Chiqish', name: 'logout', desc: '', args: []);
  }

  /// `Tizimdan chiqish`
  String get logoutConfirmTitle {
    return Intl.message(
      'Tizimdan chiqish',
      name: 'logoutConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Hisobdan chiqasizmi? Ochiq smena serverda ochiq qoladi — keyingi kirishda davom etadi.`
  String get logoutConfirmMessage {
    return Intl.message(
      'Hisobdan chiqasizmi? Ochiq smena serverda ochiq qoladi — keyingi kirishda davom etadi.',
      name: 'logoutConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Orqaga`
  String get back {
    return Intl.message('Orqaga', name: 'back', desc: '', args: []);
  }

  /// `Bekor qilish`
  String get cancel {
    return Intl.message('Bekor qilish', name: 'cancel', desc: '', args: []);
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Qayta urinish`
  String get retry {
    return Intl.message('Qayta urinish', name: 'retry', desc: '', args: []);
  }

  /// `Yangilash`
  String get refresh {
    return Intl.message('Yangilash', name: 'refresh', desc: '', args: []);
  }

  /// `SMENA TUSHUMI`
  String get shiftRevenue {
    return Intl.message(
      'SMENA TUSHUMI',
      name: 'shiftRevenue',
      desc: '',
      args: [],
    );
  }

  /// `Smena: {time} dan`
  String shiftOpenedAt(String time) {
    return Intl.message(
      'Smena: $time dan',
      name: 'shiftOpenedAt',
      desc: '',
      args: [time],
    );
  }

  /// `Smena ochilmagan`
  String get noOpenShiftTitle {
    return Intl.message(
      'Smena ochilmagan',
      name: 'noOpenShiftTitle',
      desc: '',
      args: [],
    );
  }

  /// `Sotuvni boshlash uchun smenani oching`
  String get noOpenShiftMessage {
    return Intl.message(
      'Sotuvni boshlash uchun smenani oching',
      name: 'noOpenShiftMessage',
      desc: '',
      args: [],
    );
  }

  /// `Smenani ochish`
  String get openShift {
    return Intl.message(
      'Smenani ochish',
      name: 'openShift',
      desc: '',
      args: [],
    );
  }

  /// `Hammasi`
  String get categoryAll {
    return Intl.message('Hammasi', name: 'categoryAll', desc: '', args: []);
  }

  /// `Mahsulotlarni yangilash`
  String get refreshProducts {
    return Intl.message(
      'Mahsulotlarni yangilash',
      name: 'refreshProducts',
      desc: '',
      args: [],
    );
  }

  /// `Bu barda hali faol mahsulot yo‘q`
  String get productsEmpty {
    return Intl.message(
      'Bu barda hali faol mahsulot yo‘q',
      name: 'productsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Savat`
  String get cartTitle {
    return Intl.message('Savat', name: 'cartTitle', desc: '', args: []);
  }

  /// `Savat bo‘sh — mahsulotni bosib qo‘shing`
  String get cartEmpty {
    return Intl.message(
      'Savat bo‘sh — mahsulotni bosib qo‘shing',
      name: 'cartEmpty',
      desc: '',
      args: [],
    );
  }

  /// `{count} dona`
  String cartItemsCount(int count) {
    return Intl.message(
      '$count dona',
      name: 'cartItemsCount',
      desc: '',
      args: [count],
    );
  }

  /// `Tozalash`
  String get cartClear {
    return Intl.message('Tozalash', name: 'cartClear', desc: '', args: []);
  }

  /// `Savatni tozalash`
  String get cartClearTitle {
    return Intl.message(
      'Savatni tozalash',
      name: 'cartClearTitle',
      desc: '',
      args: [],
    );
  }

  /// `Savatdagi barcha mahsulotlar o‘chiriladi. Davom etasizmi?`
  String get cartClearMessage {
    return Intl.message(
      'Savatdagi barcha mahsulotlar o‘chiriladi. Davom etasizmi?',
      name: 'cartClearMessage',
      desc: '',
      args: [],
    );
  }

  /// `Ko‘paytirish`
  String get increase {
    return Intl.message('Ko‘paytirish', name: 'increase', desc: '', args: []);
  }

  /// `Kamaytirish`
  String get decrease {
    return Intl.message('Kamaytirish', name: 'decrease', desc: '', args: []);
  }

  /// `Olib tashlash`
  String get removeLine {
    return Intl.message(
      'Olib tashlash',
      name: 'removeLine',
      desc: '',
      args: [],
    );
  }

  /// `Jami`
  String get total {
    return Intl.message('Jami', name: 'total', desc: '', args: []);
  }

  /// `Naqd`
  String get paymentCash {
    return Intl.message('Naqd', name: 'paymentCash', desc: '', args: []);
  }

  /// `Karta`
  String get paymentCard {
    return Intl.message('Karta', name: 'paymentCard', desc: '', args: []);
  }

  /// `Chek #{receiptNo} — {total} sotildi`
  String saleCompleted(int receiptNo, String total) {
    return Intl.message(
      'Chek #$receiptNo — $total sotildi',
      name: 'saleCompleted',
      desc: '',
      args: [receiptNo, total],
    );
  }

  /// `Sotuv saqlandi, lekin chek chop etilmadi. Printerni tekshiring.`
  String get receiptPrintFailed {
    return Intl.message(
      'Sotuv saqlandi, lekin chek chop etilmadi. Printerni tekshiring.',
      name: 'receiptPrintFailed',
      desc: '',
      args: [],
    );
  }

  /// `Internet aloqasi yo‘q. Savat saqlandi — to‘lov tugmasini qayta bosing, pul ikki marta yechilmaydi.`
  String get saleErrorNetwork {
    return Intl.message(
      'Internet aloqasi yo‘q. Savat saqlandi — to‘lov tugmasini qayta bosing, pul ikki marta yechilmaydi.',
      name: 'saleErrorNetwork',
      desc: '',
      args: [],
    );
  }

  /// `Serverda xatolik. Savat saqlandi — qayta urinib ko‘ring, sotuv ikki marta yozilmaydi.`
  String get saleErrorServer {
    return Intl.message(
      'Serverda xatolik. Savat saqlandi — qayta urinib ko‘ring, sotuv ikki marta yozilmaydi.',
      name: 'saleErrorServer',
      desc: '',
      args: [],
    );
  }

  /// `Server javobini o‘qib bo‘lmadi. Savat saqlandi — qayta bosing, sotuv ikki marta yozilmaydi.`
  String get saleErrorUnknownOutcome {
    return Intl.message(
      'Server javobini o‘qib bo‘lmadi. Savat saqlandi — qayta bosing, sotuv ikki marta yozilmaydi.',
      name: 'saleErrorUnknownOutcome',
      desc: '',
      args: [],
    );
  }

  /// `Internet aloqasi yo‘q. Ulanishni tekshirib, qayta urinib ko‘ring.`
  String get errorNoInternet {
    return Intl.message(
      'Internet aloqasi yo‘q. Ulanishni tekshirib, qayta urinib ko‘ring.',
      name: 'errorNoInternet',
      desc: '',
      args: [],
    );
  }

  /// `Serverda xatolik yuz berdi. Birozdan keyin qayta urinib ko‘ring.`
  String get errorServer {
    return Intl.message(
      'Serverda xatolik yuz berdi. Birozdan keyin qayta urinib ko‘ring.',
      name: 'errorServer',
      desc: '',
      args: [],
    );
  }

  /// `Nimadir noto‘g‘ri ketdi`
  String get errorUnknown {
    return Intl.message(
      'Nimadir noto‘g‘ri ketdi',
      name: 'errorUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Juda ko‘p urinish. Bir daqiqadan keyin qayta urinib ko‘ring.`
  String get errorTooManyAttempts {
    return Intl.message(
      'Juda ko‘p urinish. Bir daqiqadan keyin qayta urinib ko‘ring.',
      name: 'errorTooManyAttempts',
      desc: '',
      args: [],
    );
  }

  /// `Smena ochilmagan. Avval smenani oching.`
  String get errorShiftNotOpen {
    return Intl.message(
      'Smena ochilmagan. Avval smenani oching.',
      name: 'errorShiftNotOpen',
      desc: '',
      args: [],
    );
  }

  /// `Smena allaqachon ochilgan`
  String get errorShiftAlreadyOpen {
    return Intl.message(
      'Smena allaqachon ochilgan',
      name: 'errorShiftAlreadyOpen',
      desc: '',
      args: [],
    );
  }

  /// `Savatdagi ba’zi mahsulotlar endi sotuvda yo‘q. Ro‘yxat yangilandi — savatni tekshirib, qayta to‘lang.`
  String get errorProductUnavailable {
    return Intl.message(
      'Savatdagi ba’zi mahsulotlar endi sotuvda yo‘q. Ro‘yxat yangilandi — savatni tekshirib, qayta to‘lang.',
      name: 'errorProductUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Savat bo‘sh`
  String get errorEmptyCart {
    return Intl.message(
      'Savat bo‘sh',
      name: 'errorEmptyCart',
      desc: '',
      args: [],
    );
  }

  /// `Hisobingiz faol emas. Administratorga murojaat qiling.`
  String get errorCashierInactive {
    return Intl.message(
      'Hisobingiz faol emas. Administratorga murojaat qiling.',
      name: 'errorCashierInactive',
      desc: '',
      args: [],
    );
  }

  /// `Bu bar faol emas. Administratorga murojaat qiling.`
  String get errorBarInactive {
    return Intl.message(
      'Bu bar faol emas. Administratorga murojaat qiling.',
      name: 'errorBarInactive',
      desc: '',
      args: [],
    );
  }

  /// `Faqat joriy ochiq smenadagi sotuvni bekor qilish mumkin`
  String get errorSaleNotInShift {
    return Intl.message(
      'Faqat joriy ochiq smenadagi sotuvni bekor qilish mumkin',
      name: 'errorSaleNotInShift',
      desc: '',
      args: [],
    );
  }

  /// `Bu sotuv allaqachon bekor qilingan`
  String get errorSaleAlreadyRefunded {
    return Intl.message(
      'Bu sotuv allaqachon bekor qilingan',
      name: 'errorSaleAlreadyRefunded',
      desc: '',
      args: [],
    );
  }

  /// `Smena tarixi`
  String get historyTitle {
    return Intl.message(
      'Smena tarixi',
      name: 'historyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Bu smenada hali sotuv yo‘q`
  String get historyEmpty {
    return Intl.message(
      'Bu smenada hali sotuv yo‘q',
      name: 'historyEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Bekor qilingan`
  String get statusRefunded {
    return Intl.message(
      'Bekor qilingan',
      name: 'statusRefunded',
      desc: '',
      args: [],
    );
  }

  /// `Bekor qilish`
  String get refund {
    return Intl.message('Bekor qilish', name: 'refund', desc: '', args: []);
  }

  /// `Chek #{receiptNo} ni bekor qilish`
  String refundTitle(int receiptNo) {
    return Intl.message(
      'Chek #$receiptNo ni bekor qilish',
      name: 'refundTitle',
      desc: '',
      args: [receiptNo],
    );
  }

  /// `Butun sotuv bekor qilinadi va {total} smena tushumidan chiqariladi. Pulni xaridorga qaytaring.`
  String refundMessage(String total) {
    return Intl.message(
      'Butun sotuv bekor qilinadi va $total smena tushumidan chiqariladi. Pulni xaridorga qaytaring.',
      name: 'refundMessage',
      desc: '',
      args: [total],
    );
  }

  /// `Sabab (ixtiyoriy)`
  String get refundReasonOptional {
    return Intl.message(
      'Sabab (ixtiyoriy)',
      name: 'refundReasonOptional',
      desc: '',
      args: [],
    );
  }

  /// `Ha, bekor qilish`
  String get refundConfirm {
    return Intl.message(
      'Ha, bekor qilish',
      name: 'refundConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Chek #{receiptNo} bekor qilindi`
  String refundDone(int receiptNo) {
    return Intl.message(
      'Chek #$receiptNo bekor qilindi',
      name: 'refundDone',
      desc: '',
      args: [receiptNo],
    );
  }

  /// `Sabab: {reason}`
  String refundReasonShown(String reason) {
    return Intl.message(
      'Sabab: $reason',
      name: 'refundReasonShown',
      desc: '',
      args: [reason],
    );
  }

  /// `Smenani yopish`
  String get closeShift {
    return Intl.message(
      'Smenani yopish',
      name: 'closeShift',
      desc: '',
      args: [],
    );
  }

  /// `Cheklar`
  String get receiptsCount {
    return Intl.message('Cheklar', name: 'receiptsCount', desc: '', args: []);
  }

  /// `Bekor qilinganlar`
  String get refundedCount {
    return Intl.message(
      'Bekor qilinganlar',
      name: 'refundedCount',
      desc: '',
      args: [],
    );
  }

  /// `Kassadagi naqd pul (sanalgan)`
  String get countedCash {
    return Intl.message(
      'Kassadagi naqd pul (sanalgan)',
      name: 'countedCash',
      desc: '',
      args: [],
    );
  }

  /// `Kassadagi naqd pulni sanab kiriting`
  String get countedCashHint {
    return Intl.message(
      'Kassadagi naqd pulni sanab kiriting',
      name: 'countedCashHint',
      desc: '',
      args: [],
    );
  }

  /// `Kutilgan naqd`
  String get expectedCash {
    return Intl.message(
      'Kutilgan naqd',
      name: 'expectedCash',
      desc: '',
      args: [],
    );
  }

  /// `Farq`
  String get cashDifference {
    return Intl.message('Farq', name: 'cashDifference', desc: '', args: []);
  }

  /// `Izoh (ixtiyoriy)`
  String get noteOptional {
    return Intl.message(
      'Izoh (ixtiyoriy)',
      name: 'noteOptional',
      desc: '',
      args: [],
    );
  }

  /// `Smenani yopasizmi?`
  String get closeShiftConfirmTitle {
    return Intl.message(
      'Smenani yopasizmi?',
      name: 'closeShiftConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Yopilgan smenada sotuv va bekor qilish mumkin bo‘lmaydi.`
  String get closeShiftConfirmMessage {
    return Intl.message(
      'Yopilgan smenada sotuv va bekor qilish mumkin bo‘lmaydi.',
      name: 'closeShiftConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Smena yopildi`
  String get shiftClosedTitle {
    return Intl.message(
      'Smena yopildi',
      name: 'shiftClosedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Smena vaqti`
  String get shiftPeriod {
    return Intl.message('Smena vaqti', name: 'shiftPeriod', desc: '', args: []);
  }

  /// `Bar`
  String get barLabel {
    return Intl.message('Bar', name: 'barLabel', desc: '', args: []);
  }

  /// `Versiya`
  String get version {
    return Intl.message('Versiya', name: 'version', desc: '', args: []);
  }

  /// `Chek printeri`
  String get printerSettings {
    return Intl.message(
      'Chek printeri',
      name: 'printerSettings',
      desc: '',
      args: [],
    );
  }

  /// `Printer`
  String get receiptPrinter {
    return Intl.message('Printer', name: 'receiptPrinter', desc: '', args: []);
  }

  /// `Printer yo‘q (chek chop etilmaydi)`
  String get printerNone {
    return Intl.message(
      'Printer yo‘q (chek chop etilmaydi)',
      name: 'printerNone',
      desc: '',
      args: [],
    );
  }

  /// `{name} (hozir ulanmagan)`
  String printerUnavailable(String name) {
    return Intl.message(
      '$name (hozir ulanmagan)',
      name: 'printerUnavailable',
      desc: '',
      args: [name],
    );
  }

  /// `Printer tanlansa, har bir sotuvdan keyin chek avtomatik chop etiladi.`
  String get printerHint {
    return Intl.message(
      'Printer tanlansa, har bir sotuvdan keyin chek avtomatik chop etiladi.',
      name: 'printerHint',
      desc: '',
      args: [],
    );
  }

  /// `Kompyuterda o‘rnatilgan printer topilmadi`
  String get noPrintersFound {
    return Intl.message(
      'Kompyuterda o‘rnatilgan printer topilmadi',
      name: 'noPrintersFound',
      desc: '',
      args: [],
    );
  }

  /// `Yangilanish`
  String get updateTitle {
    return Intl.message('Yangilanish', name: 'updateTitle', desc: '', args: []);
  }

  /// `Yangilanishni tekshirish`
  String get updateCheck {
    return Intl.message(
      'Yangilanishni tekshirish',
      name: 'updateCheck',
      desc: '',
      args: [],
    );
  }

  /// `Eng so‘nggi versiya o‘rnatilgan`
  String get updateUpToDate {
    return Intl.message(
      'Eng so‘nggi versiya o‘rnatilgan',
      name: 'updateUpToDate',
      desc: '',
      args: [],
    );
  }

  /// `Yangi versiya mavjud: {version}`
  String updateAvailable(String version) {
    return Intl.message(
      'Yangi versiya mavjud: $version',
      name: 'updateAvailable',
      desc: '',
      args: [version],
    );
  }

  /// `Yuklab olish va o‘rnatish`
  String get updateDownload {
    return Intl.message(
      'Yuklab olish va o‘rnatish',
      name: 'updateDownload',
      desc: '',
      args: [],
    );
  }

  /// `Yuklanmoqda…`
  String get updateDownloading {
    return Intl.message(
      'Yuklanmoqda…',
      name: 'updateDownloading',
      desc: '',
      args: [],
    );
  }

  /// `Yangilanish tayyor`
  String get updateReady {
    return Intl.message(
      'Yangilanish tayyor',
      name: 'updateReady',
      desc: '',
      args: [],
    );
  }

  /// `Qayta ishga tushirish`
  String get updateRestart {
    return Intl.message(
      'Qayta ishga tushirish',
      name: 'updateRestart',
      desc: '',
      args: [],
    );
  }

  /// `Ilovani yangilash`
  String get updateConfirmTitle {
    return Intl.message(
      'Ilovani yangilash',
      name: 'updateConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Ilova yopiladi va yangi versiyada qayta ochiladi. Smena ochiq qoladi. Davom etasizmi?`
  String get updateConfirmMessage {
    return Intl.message(
      'Ilova yopiladi va yangi versiyada qayta ochiladi. Smena ochiq qoladi. Davom etasizmi?',
      name: 'updateConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Davom etish`
  String get updateConfirm {
    return Intl.message(
      'Davom etish',
      name: 'updateConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Bekor qilish`
  String get updateCancel {
    return Intl.message(
      'Bekor qilish',
      name: 'updateCancel',
      desc: '',
      args: [],
    );
  }

  /// `Yangilanmadi`
  String get updateFailed {
    return Intl.message(
      'Yangilanmadi',
      name: 'updateFailed',
      desc: '',
      args: [],
    );
  }

  /// `Yangilanmadi. Internet aloqasini tekshiring va qayta urinib ko‘ring.`
  String get updateFailedGeneric {
    return Intl.message(
      'Yangilanmadi. Internet aloqasini tekshiring va qayta urinib ko‘ring.',
      name: 'updateFailedGeneric',
      desc: '',
      args: [],
    );
  }

  /// `Qo‘lda yuklab olish uchun:`
  String get updateManualHint {
    return Intl.message(
      'Qo‘lda yuklab olish uchun:',
      name: 'updateManualHint',
      desc: '',
      args: [],
    );
  }

  /// `Avtomatik yangilash faqat Windows’da ishlaydi`
  String get updateWindowsOnly {
    return Intl.message(
      'Avtomatik yangilash faqat Windows’da ishlaydi',
      name: 'updateWindowsOnly',
      desc: '',
      args: [],
    );
  }

  /// `Yuklab olingan fayl buzilgan chiqdi — tekshiruv summasi mos kelmadi`
  String get updateFailureChecksumMismatch {
    return Intl.message(
      'Yuklab olingan fayl buzilgan chiqdi — tekshiruv summasi mos kelmadi',
      name: 'updateFailureChecksumMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Nashr etilgan tekshiruv summasini o‘qib bo‘lmadi — tasdiqlanmagan yangilanish o‘rnatilmaydi`
  String get updateFailureChecksumUnreadable {
    return Intl.message(
      'Nashr etilgan tekshiruv summasini o‘qib bo‘lmadi — tasdiqlanmagan yangilanish o‘rnatilmaydi',
      name: 'updateFailureChecksumUnreadable',
      desc: '',
      args: [],
    );
  }

  /// `Yuklab olingan arxivda ilova dasturi topilmadi`
  String get updateFailureExecutableMissing {
    return Intl.message(
      'Yuklab olingan arxivda ilova dasturi topilmadi',
      name: 'updateFailureExecutableMissing',
      desc: '',
      args: [],
    );
  }

  /// `Yangilanish to‘liq yozilmadi. Yuklangan fayl bekor qilindi — qaytadan urinib ko‘ring`
  String get updateFailureIncompleteExtraction {
    return Intl.message(
      'Yangilanish to‘liq yozilmadi. Yuklangan fayl bekor qilindi — qaytadan urinib ko‘ring',
      name: 'updateFailureIncompleteExtraction',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'uz'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppLocalization> load(Locale locale) => AppLocalization.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
