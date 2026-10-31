// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a uz locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'uz';

  static String m0(count) => "${count} dona";

  static String m1(name, amount) =>
      "“${name}” — ${amount} o‘chiriladi. Davom etasizmi?";

  static String m2(name, amount) => "Chiqim saqlandi: ${name} — ${amount}";

  static String m3(amount) => "Kassadan: ${amount}";

  static String m4(name, amount) =>
      "“${name}” — ${amount} o‘chiriladi. Davom etasizmi?";

  static String m5(name, amount) => "Kirim saqlandi: ${name} — ${amount}";

  static String m6(amount) => "Kassaga: ${amount}";

  static String m7(qty) => "Kamida: ${qty}";

  static String m8(cash, card) => "N ${cash} · K ${card}";

  static String m9(total) => "Jami: ${total}";

  static String m10(qty) => "Bo‘ladi: ${qty}";

  static String m11(qty) => "Omborda buncha yo‘q (qoldiq: ${qty})";

  static String m12(name) => "${name} (hozir ulanmagan)";

  static String m13(name) => "Retsept: ${name}";

  static String m14(receiptNo) => "Chek #${receiptNo} bekor qilindi";

  static String m15(total) =>
      "Butun sotuv bekor qilinadi va ${total} smena tushumidan chiqariladi. Pulni xaridorga qaytaring.";

  static String m16(reason) => "Sabab: ${reason}";

  static String m17(receiptNo) => "Chek #${receiptNo} ni bekor qilish";

  static String m18(receiptNo, total) =>
      "Chek #${receiptNo} — ${total} sotildi";

  static String m19(time) => "Smena: ${time} dan";

  static String m20(version) => "Yangi versiya mavjud: ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "appTitle": MessageLookupByLibrary.simpleMessage("Pixel Bar"),
    "back": MessageLookupByLibrary.simpleMessage("Orqaga"),
    "barLabel": MessageLookupByLibrary.simpleMessage("Bar"),
    "cancel": MessageLookupByLibrary.simpleMessage("Bekor qilish"),
    "cartClear": MessageLookupByLibrary.simpleMessage("Tozalash"),
    "cartClearMessage": MessageLookupByLibrary.simpleMessage(
      "Savatdagi barcha mahsulotlar o‘chiriladi. Davom etasizmi?",
    ),
    "cartClearTitle": MessageLookupByLibrary.simpleMessage("Savatni tozalash"),
    "cartEmpty": MessageLookupByLibrary.simpleMessage(
      "Savat bo‘sh — mahsulotni bosib qo‘shing",
    ),
    "cartItemsCount": m0,
    "cartTitle": MessageLookupByLibrary.simpleMessage("Savat"),
    "cashDifference": MessageLookupByLibrary.simpleMessage("Farq"),
    "cashExpenses": MessageLookupByLibrary.simpleMessage("Kassadan chiqim"),
    "cashIncomes": MessageLookupByLibrary.simpleMessage("Kassaga kirim"),
    "cashSales": MessageLookupByLibrary.simpleMessage("Naqd savdo"),
    "categoryAll": MessageLookupByLibrary.simpleMessage("Hammasi"),
    "closeShift": MessageLookupByLibrary.simpleMessage("Smenani yopish"),
    "closeShiftConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "Yopilgan smenada sotuv va bekor qilish mumkin bo‘lmaydi.",
    ),
    "closeShiftConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Smenani yopasizmi?",
    ),
    "countedCash": MessageLookupByLibrary.simpleMessage(
      "Kassadagi naqd pul (sanalgan)",
    ),
    "countedCashHint": MessageLookupByLibrary.simpleMessage(
      "Kassadagi naqd pulni sanab kiriting",
    ),
    "decrease": MessageLookupByLibrary.simpleMessage("Kamaytirish"),
    "errorBarInactive": MessageLookupByLibrary.simpleMessage(
      "Bu bar faol emas. Administratorga murojaat qiling.",
    ),
    "errorCashierInactive": MessageLookupByLibrary.simpleMessage(
      "Hisobingiz faol emas. Administratorga murojaat qiling.",
    ),
    "errorEmptyCart": MessageLookupByLibrary.simpleMessage("Savat bo‘sh"),
    "errorExpenseNotFound": MessageLookupByLibrary.simpleMessage(
      "Chiqim topilmadi. Faqat ochiq smenadagi o‘z chiqimingizni o‘chirish mumkin.",
    ),
    "errorIncomeNotFound": MessageLookupByLibrary.simpleMessage(
      "Kirim topilmadi. Faqat ochiq smenadagi o‘z kirimingizni o‘chirish mumkin.",
    ),
    "errorInvalidPaymentSplit": MessageLookupByLibrary.simpleMessage(
      "Naqd va karta summasi jami summaga to‘g‘ri kelmadi. Aralash to‘lovni qaytadan kiriting.",
    ),
    "errorNoInternet": MessageLookupByLibrary.simpleMessage(
      "Internet aloqasi yo‘q. Ulanishni tekshirib, qayta urinib ko‘ring.",
    ),
    "errorProductUnavailable": MessageLookupByLibrary.simpleMessage(
      "Savatdagi ba’zi mahsulotlar endi sotuvda yo‘q. Ro‘yxat yangilandi — savatni tekshirib, qayta to‘lang.",
    ),
    "errorSaleAlreadyRefunded": MessageLookupByLibrary.simpleMessage(
      "Bu sotuv allaqachon bekor qilingan",
    ),
    "errorSaleNotInShift": MessageLookupByLibrary.simpleMessage(
      "Faqat joriy ochiq smenadagi sotuvni bekor qilish mumkin",
    ),
    "errorServer": MessageLookupByLibrary.simpleMessage(
      "Serverda xatolik yuz berdi. Birozdan keyin qayta urinib ko‘ring.",
    ),
    "errorShiftAlreadyOpen": MessageLookupByLibrary.simpleMessage(
      "Smena allaqachon ochilgan",
    ),
    "errorShiftNotOpen": MessageLookupByLibrary.simpleMessage(
      "Smena ochilmagan. Avval smenani oching.",
    ),
    "errorTooManyAttempts": MessageLookupByLibrary.simpleMessage(
      "Juda ko‘p urinish. Bir daqiqadan keyin qayta urinib ko‘ring.",
    ),
    "errorUnknown": MessageLookupByLibrary.simpleMessage(
      "Nimadir noto‘g‘ri ketdi",
    ),
    "expectedCash": MessageLookupByLibrary.simpleMessage("Kutilgan naqd"),
    "expenseAmount": MessageLookupByLibrary.simpleMessage("Summa"),
    "expenseAmountInvalid": MessageLookupByLibrary.simpleMessage(
      "Summani kiriting (0 dan katta, 1 mlrd dan oshmasin)",
    ),
    "expenseDelete": MessageLookupByLibrary.simpleMessage("O‘chirish"),
    "expenseDeleteConfirm": MessageLookupByLibrary.simpleMessage(
      "Ha, o‘chirish",
    ),
    "expenseDeleteMessage": m1,
    "expenseDeleteTitle": MessageLookupByLibrary.simpleMessage(
      "Chiqimni o‘chirish",
    ),
    "expenseDeleted": MessageLookupByLibrary.simpleMessage("Chiqim o‘chirildi"),
    "expenseName": MessageLookupByLibrary.simpleMessage("Nomi"),
    "expenseNameHint": MessageLookupByLibrary.simpleMessage("Masalan: Sut"),
    "expenseNameRequired": MessageLookupByLibrary.simpleMessage(
      "Nomini kiriting",
    ),
    "expenseNew": MessageLookupByLibrary.simpleMessage("Yangi chiqim"),
    "expensePaidFrom": MessageLookupByLibrary.simpleMessage(
      "Qayerdan to‘landi",
    ),
    "expenseQuickPick": MessageLookupByLibrary.simpleMessage("Tez tanlash"),
    "expenseSave": MessageLookupByLibrary.simpleMessage("Saqlash"),
    "expenseSaved": m2,
    "expensesEmpty": MessageLookupByLibrary.simpleMessage(
      "Bu smenada hali chiqim yo‘q",
    ),
    "expensesEmptyHint": MessageLookupByLibrary.simpleMessage(
      "Kassadan yoki boshqa manbadan to‘langan xarajatni “Yangi chiqim” orqali yozing",
    ),
    "expensesFromCashTotal": m3,
    "expensesShiftTotal": MessageLookupByLibrary.simpleMessage("SMENA CHIQIMI"),
    "expensesTitle": MessageLookupByLibrary.simpleMessage("Chiqimlar"),
    "historyEmpty": MessageLookupByLibrary.simpleMessage(
      "Bu smenada hali sotuv yo‘q",
    ),
    "historyTitle": MessageLookupByLibrary.simpleMessage("Smena tarixi"),
    "incomeAmount": MessageLookupByLibrary.simpleMessage("Summa"),
    "incomeAmountInvalid": MessageLookupByLibrary.simpleMessage(
      "Summani kiriting (0 dan katta, 1 mlrd dan oshmasin)",
    ),
    "incomeDelete": MessageLookupByLibrary.simpleMessage("O‘chirish"),
    "incomeDeleteConfirm": MessageLookupByLibrary.simpleMessage(
      "Ha, o‘chirish",
    ),
    "incomeDeleteMessage": m4,
    "incomeDeleteTitle": MessageLookupByLibrary.simpleMessage(
      "Kirimni o‘chirish",
    ),
    "incomeDeleted": MessageLookupByLibrary.simpleMessage("Kirim o‘chirildi"),
    "incomeName": MessageLookupByLibrary.simpleMessage("Nomi"),
    "incomeNameHint": MessageLookupByLibrary.simpleMessage("Masalan: Depozit"),
    "incomeNameRequired": MessageLookupByLibrary.simpleMessage(
      "Nomini kiriting",
    ),
    "incomeNew": MessageLookupByLibrary.simpleMessage("Yangi kirim"),
    "incomeQuickPick": MessageLookupByLibrary.simpleMessage("Tez tanlash"),
    "incomeReceivedTo": MessageLookupByLibrary.simpleMessage("Qayerga tushdi"),
    "incomeSave": MessageLookupByLibrary.simpleMessage("Saqlash"),
    "incomeSaved": m5,
    "incomesEmpty": MessageLookupByLibrary.simpleMessage(
      "Bu smenada hali kirim yo‘q",
    ),
    "incomesEmptyHint": MessageLookupByLibrary.simpleMessage(
      "Kassaga yoki boshqa joyga kelgan pulni “Yangi kirim” orqali yozing",
    ),
    "incomesFromCashTotal": m6,
    "incomesShiftTotal": MessageLookupByLibrary.simpleMessage("SMENA KIRIMI"),
    "incomesTitle": MessageLookupByLibrary.simpleMessage("Kirimlar"),
    "increase": MessageLookupByLibrary.simpleMessage("Ko‘paytirish"),
    "inventoryAll": MessageLookupByLibrary.simpleMessage("Hammasi"),
    "inventoryClose": MessageLookupByLibrary.simpleMessage("Yopish"),
    "inventoryEdit": MessageLookupByLibrary.simpleMessage("Tahrirlash"),
    "inventoryEmpty": MessageLookupByLibrary.simpleMessage(
      "Omborda hali mahsulot yo‘q",
    ),
    "inventoryEmptyHint": MessageLookupByLibrary.simpleMessage(
      "“Yangi mahsulot” orqali kofe, sut, shakar kabilarni qo‘shing",
    ),
    "inventoryEmptyLow": MessageLookupByLibrary.simpleMessage(
      "Kam qolgan mahsulot yo‘q",
    ),
    "inventoryEmptySearch": MessageLookupByLibrary.simpleMessage(
      "Hech narsa topilmadi",
    ),
    "inventoryInactive": MessageLookupByLibrary.simpleMessage("Nofaol"),
    "inventoryLoadMore": MessageLookupByLibrary.simpleMessage("Yana yuklash"),
    "inventoryLowFilter": MessageLookupByLibrary.simpleMessage("Kam qolganlar"),
    "inventoryMinQty": m7,
    "inventoryMovements": MessageLookupByLibrary.simpleMessage(
      "Oxirgi harakatlar",
    ),
    "inventoryNewItem": MessageLookupByLibrary.simpleMessage("Yangi mahsulot"),
    "inventoryNoMovements": MessageLookupByLibrary.simpleMessage(
      "Harakatlar yo‘q",
    ),
    "inventoryOnHand": MessageLookupByLibrary.simpleMessage("Qoldiq"),
    "inventorySave": MessageLookupByLibrary.simpleMessage("Saqlash"),
    "inventorySaved": MessageLookupByLibrary.simpleMessage("Saqlandi"),
    "inventorySearchHint": MessageLookupByLibrary.simpleMessage(
      "Mahsulot qidirish",
    ),
    "inventoryStatusLow": MessageLookupByLibrary.simpleMessage("Kam"),
    "inventoryStatusOk": MessageLookupByLibrary.simpleMessage("Yetarli"),
    "inventoryStatusOut": MessageLookupByLibrary.simpleMessage("Tugadi"),
    "inventoryTapHint": MessageLookupByLibrary.simpleMessage(
      "Mahsulotni bosing: sanash, tahrirlash, tarix",
    ),
    "inventoryTitle": MessageLookupByLibrary.simpleMessage("Ombor"),
    "inventoryUnavailable": MessageLookupByLibrary.simpleMessage(
      "Ombor hozircha mavjud emas. Savdo odatdagidek ishlayveradi.",
    ),
    "itemActive": MessageLookupByLibrary.simpleMessage("Faol"),
    "itemEditTitle": MessageLookupByLibrary.simpleMessage(
      "Mahsulotni tahrirlash",
    ),
    "itemMinQty": MessageLookupByLibrary.simpleMessage("Kam qolish chegarasi"),
    "itemMinQtyInvalid": MessageLookupByLibrary.simpleMessage(
      "Chegarani to‘g‘ri kiriting (0 yoki undan katta)",
    ),
    "itemName": MessageLookupByLibrary.simpleMessage("Nomi"),
    "itemNameHint": MessageLookupByLibrary.simpleMessage("Masalan: Kofe"),
    "itemNameRequired": MessageLookupByLibrary.simpleMessage("Nomini kiriting"),
    "itemUnit": MessageLookupByLibrary.simpleMessage("O‘lchov birligi"),
    "language": MessageLookupByLibrary.simpleMessage("Til"),
    "languageRussian": MessageLookupByLibrary.simpleMessage("Русский"),
    "languageUzbek": MessageLookupByLibrary.simpleMessage("O‘zbekcha"),
    "loginButton": MessageLookupByLibrary.simpleMessage("Kirish"),
    "loginInvalid": MessageLookupByLibrary.simpleMessage(
      "Login yoki parol noto‘g‘ri",
    ),
    "loginPassword": MessageLookupByLibrary.simpleMessage("Parol"),
    "loginShowPassword": MessageLookupByLibrary.simpleMessage(
      "Parolni ko‘rsatish",
    ),
    "loginSubtitle": MessageLookupByLibrary.simpleMessage(
      "Bar kassasiga kirish uchun login va parolni kiriting",
    ),
    "loginUsername": MessageLookupByLibrary.simpleMessage("Login"),
    "logout": MessageLookupByLibrary.simpleMessage("Chiqish"),
    "logoutConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "Hisobdan chiqasizmi? Ochiq smena serverda ochiq qoladi — keyingi kirishda davom etadi.",
    ),
    "logoutConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Tizimdan chiqish",
    ),
    "menu": MessageLookupByLibrary.simpleMessage("Menyu"),
    "menuCloseShift": MessageLookupByLibrary.simpleMessage("Smenani yopish"),
    "menuExpenses": MessageLookupByLibrary.simpleMessage("Chiqimlar"),
    "menuHistory": MessageLookupByLibrary.simpleMessage("Smena tarixi"),
    "menuIncomes": MessageLookupByLibrary.simpleMessage("Kirimlar"),
    "menuInventory": MessageLookupByLibrary.simpleMessage("Ombor"),
    "menuSettings": MessageLookupByLibrary.simpleMessage("Sozlamalar"),
    "mixedInvalid": MessageLookupByLibrary.simpleMessage(
      "Naqd va karta jami summaga teng bo‘lishi kerak",
    ),
    "mixedPay": MessageLookupByLibrary.simpleMessage("To‘lash"),
    "mixedSplitShort": m8,
    "mixedTitle": MessageLookupByLibrary.simpleMessage("Aralash to‘lov"),
    "mixedTotal": m9,
    "movAdjustment": MessageLookupByLibrary.simpleMessage("Sanash"),
    "movOther": MessageLookupByLibrary.simpleMessage("Boshqa"),
    "movReceipt": MessageLookupByLibrary.simpleMessage("Kirim"),
    "movRefund": MessageLookupByLibrary.simpleMessage("Qaytarish"),
    "movSale": MessageLookupByLibrary.simpleMessage("Savdo"),
    "movWriteoff": MessageLookupByLibrary.simpleMessage("Brak"),
    "noOpenShiftMessage": MessageLookupByLibrary.simpleMessage(
      "Sotuvni boshlash uchun smenani oching",
    ),
    "noOpenShiftTitle": MessageLookupByLibrary.simpleMessage(
      "Smena ochilmagan",
    ),
    "noPrintersFound": MessageLookupByLibrary.simpleMessage(
      "Kompyuterda o‘rnatilgan printer topilmadi",
    ),
    "noteOptional": MessageLookupByLibrary.simpleMessage("Izoh (ixtiyoriy)"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "opAfter": m10,
    "opComment": MessageLookupByLibrary.simpleMessage("Izoh (ixtiyoriy)"),
    "opCount": MessageLookupByLibrary.simpleMessage("Sanash"),
    "opCountHint": MessageLookupByLibrary.simpleMessage(
      "Hozir omborda haqiqatda qancha bor? Qoldiq shunga tenglashtiriladi.",
    ),
    "opExceeds": m11,
    "opReason": MessageLookupByLibrary.simpleMessage("Sabab"),
    "opReasonRequired": MessageLookupByLibrary.simpleMessage(
      "Sababni kiriting (kamida 2 belgi)",
    ),
    "opReceipt": MessageLookupByLibrary.simpleMessage("Kirim"),
    "opWriteoff": MessageLookupByLibrary.simpleMessage("Brak"),
    "openShift": MessageLookupByLibrary.simpleMessage("Smenani ochish"),
    "paidFromCash": MessageLookupByLibrary.simpleMessage("Kassadan"),
    "paidFromOther": MessageLookupByLibrary.simpleMessage("Boshqa"),
    "paymentCard": MessageLookupByLibrary.simpleMessage("Karta"),
    "paymentCash": MessageLookupByLibrary.simpleMessage("Naqd"),
    "paymentMixed": MessageLookupByLibrary.simpleMessage("Aralash"),
    "printerHint": MessageLookupByLibrary.simpleMessage(
      "Printer tanlansa, har bir sotuvdan keyin chek avtomatik chop etiladi.",
    ),
    "printerNone": MessageLookupByLibrary.simpleMessage(
      "Printer yo‘q (chek chop etilmaydi)",
    ),
    "printerSettings": MessageLookupByLibrary.simpleMessage("Chek printeri"),
    "printerUnavailable": m12,
    "productsEmpty": MessageLookupByLibrary.simpleMessage(
      "Bu barda hali faol mahsulot yo‘q",
    ),
    "qtyCountInvalid": MessageLookupByLibrary.simpleMessage(
      "Sanalgan miqdorni kiriting (0 yoki undan katta)",
    ),
    "qtyInvalid": MessageLookupByLibrary.simpleMessage(
      "Miqdorni kiriting (0 dan katta)",
    ),
    "qtyLabel": MessageLookupByLibrary.simpleMessage("Miqdor"),
    "reasonBroken": MessageLookupByLibrary.simpleMessage("Sindi"),
    "reasonExpired": MessageLookupByLibrary.simpleMessage("Muddati o‘tdi"),
    "reasonOther": MessageLookupByLibrary.simpleMessage("Boshqa"),
    "reasonSpilled": MessageLookupByLibrary.simpleMessage("To‘kilib ketdi"),
    "receiptCashier": MessageLookupByLibrary.simpleMessage("Kassir"),
    "receiptCheckNo": MessageLookupByLibrary.simpleMessage("Chek №"),
    "receiptCurrency": MessageLookupByLibrary.simpleMessage("so‘m"),
    "receiptDate": MessageLookupByLibrary.simpleMessage("Sana"),
    "receiptPaymentMethod": MessageLookupByLibrary.simpleMessage(
      "To‘lov usuli",
    ),
    "receiptPrintFailed": MessageLookupByLibrary.simpleMessage(
      "Sotuv saqlandi, lekin chek chop etilmadi. Printerni tekshiring.",
    ),
    "receiptPrinter": MessageLookupByLibrary.simpleMessage("Printer"),
    "receiptRefunded": MessageLookupByLibrary.simpleMessage("BEKOR QILINGAN"),
    "receiptThanks": MessageLookupByLibrary.simpleMessage(
      "Xaridingiz uchun rahmat!",
    ),
    "receiptTotal": MessageLookupByLibrary.simpleMessage("JAMI"),
    "receiptsCount": MessageLookupByLibrary.simpleMessage("Cheklar"),
    "receivedToCash": MessageLookupByLibrary.simpleMessage("Kassaga"),
    "receivedToOther": MessageLookupByLibrary.simpleMessage("Boshqa"),
    "recipeAddIngredient": MessageLookupByLibrary.simpleMessage(
      "Ingredient qo‘shish",
    ),
    "recipeDuplicate": MessageLookupByLibrary.simpleMessage(
      "Bir ingredient ikki marta tanlangan",
    ),
    "recipeEditorTitle": m13,
    "recipeEmptyInfo": MessageLookupByLibrary.simpleMessage(
      "Bo‘sh: bu mahsulot sotilganda ombordan hech narsa ayirilmaydi",
    ),
    "recipeIncomplete": MessageLookupByLibrary.simpleMessage(
      "Har bir ingredientni va uning miqdorini to‘ldiring",
    ),
    "recipeIngredient": MessageLookupByLibrary.simpleMessage("Ingredient"),
    "recipeKindPrepared": MessageLookupByLibrary.simpleMessage(
      "Retsept (porsiyaga)",
    ),
    "recipeKindReady": MessageLookupByLibrary.simpleMessage(
      "Tayyor mahsulot (donasiga)",
    ),
    "recipeNoItems": MessageLookupByLibrary.simpleMessage(
      "Avval omborga mahsulot qo‘shing",
    ),
    "recipeSaved": MessageLookupByLibrary.simpleMessage("Retsept saqlandi"),
    "recipesButton": MessageLookupByLibrary.simpleMessage("Retseptlar"),
    "recipesEmpty": MessageLookupByLibrary.simpleMessage(
      "Sotuv mahsulotlari topilmadi",
    ),
    "recipesHint": MessageLookupByLibrary.simpleMessage(
      "Mahsulotni tanlang va bir porsiyaga ketadigan ingredientlarni belgilang. Sotilganda ombordan avtomatik ayriladi.",
    ),
    "recipesTitle": MessageLookupByLibrary.simpleMessage("Retseptlar"),
    "refresh": MessageLookupByLibrary.simpleMessage("Yangilash"),
    "refreshProducts": MessageLookupByLibrary.simpleMessage(
      "Mahsulotlarni yangilash",
    ),
    "refund": MessageLookupByLibrary.simpleMessage("Bekor qilish"),
    "refundConfirm": MessageLookupByLibrary.simpleMessage("Ha, bekor qilish"),
    "refundDone": m14,
    "refundMessage": m15,
    "refundReasonOptional": MessageLookupByLibrary.simpleMessage(
      "Sabab (ixtiyoriy)",
    ),
    "refundReasonShown": m16,
    "refundTitle": m17,
    "refundedCount": MessageLookupByLibrary.simpleMessage("Bekor qilinganlar"),
    "removeLine": MessageLookupByLibrary.simpleMessage("Olib tashlash"),
    "retry": MessageLookupByLibrary.simpleMessage("Qayta urinish"),
    "saleCompleted": m18,
    "saleErrorNetwork": MessageLookupByLibrary.simpleMessage(
      "Internet aloqasi yo‘q. Savat saqlandi — to‘lov tugmasini qayta bosing, pul ikki marta yechilmaydi.",
    ),
    "saleErrorServer": MessageLookupByLibrary.simpleMessage(
      "Serverda xatolik. Savat saqlandi — qayta urinib ko‘ring, sotuv ikki marta yozilmaydi.",
    ),
    "saleErrorUnknownOutcome": MessageLookupByLibrary.simpleMessage(
      "Server javobini o‘qib bo‘lmadi. Savat saqlandi — qayta bosing, sotuv ikki marta yozilmaydi.",
    ),
    "shiftClosedTitle": MessageLookupByLibrary.simpleMessage("Smena yopildi"),
    "shiftExpenses": MessageLookupByLibrary.simpleMessage("Chiqimlar"),
    "shiftIncomes": MessageLookupByLibrary.simpleMessage("Kirimlar"),
    "shiftOpenedAt": m19,
    "shiftPeriod": MessageLookupByLibrary.simpleMessage("Smena vaqti"),
    "shiftRevenue": MessageLookupByLibrary.simpleMessage("SMENA TUSHUMI"),
    "statusRefunded": MessageLookupByLibrary.simpleMessage("Bekor qilingan"),
    "total": MessageLookupByLibrary.simpleMessage("Jami"),
    "unitGram": MessageLookupByLibrary.simpleMessage("Gramm (g, kg)"),
    "unitMl": MessageLookupByLibrary.simpleMessage("Millilitr (ml, l)"),
    "unitPcs": MessageLookupByLibrary.simpleMessage("Dona"),
    "updateAvailable": m20,
    "updateCancel": MessageLookupByLibrary.simpleMessage("Bekor qilish"),
    "updateCheck": MessageLookupByLibrary.simpleMessage(
      "Yangilanishni tekshirish",
    ),
    "updateConfirm": MessageLookupByLibrary.simpleMessage("Davom etish"),
    "updateConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "Ilova yopiladi va yangi versiyada qayta ochiladi. Smena ochiq qoladi. Davom etasizmi?",
    ),
    "updateConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Ilovani yangilash",
    ),
    "updateDownload": MessageLookupByLibrary.simpleMessage(
      "Yuklab olish va o‘rnatish",
    ),
    "updateDownloading": MessageLookupByLibrary.simpleMessage("Yuklanmoqda…"),
    "updateFailed": MessageLookupByLibrary.simpleMessage("Yangilanmadi"),
    "updateFailedGeneric": MessageLookupByLibrary.simpleMessage(
      "Yangilanmadi. Internet aloqasini tekshiring va qayta urinib ko‘ring.",
    ),
    "updateFailureChecksumMismatch": MessageLookupByLibrary.simpleMessage(
      "Yuklab olingan fayl buzilgan chiqdi — tekshiruv summasi mos kelmadi",
    ),
    "updateFailureChecksumUnreadable": MessageLookupByLibrary.simpleMessage(
      "Nashr etilgan tekshiruv summasini o‘qib bo‘lmadi — tasdiqlanmagan yangilanish o‘rnatilmaydi",
    ),
    "updateFailureExecutableMissing": MessageLookupByLibrary.simpleMessage(
      "Yuklab olingan arxivda ilova dasturi topilmadi",
    ),
    "updateFailureIncompleteExtraction": MessageLookupByLibrary.simpleMessage(
      "Yangilanish to‘liq yozilmadi. Yuklangan fayl bekor qilindi — qaytadan urinib ko‘ring",
    ),
    "updateManualHint": MessageLookupByLibrary.simpleMessage(
      "Qo‘lda yuklab olish uchun:",
    ),
    "updateReady": MessageLookupByLibrary.simpleMessage("Yangilanish tayyor"),
    "updateRestart": MessageLookupByLibrary.simpleMessage(
      "Qayta ishga tushirish",
    ),
    "updateTitle": MessageLookupByLibrary.simpleMessage("Yangilanish"),
    "updateUpToDate": MessageLookupByLibrary.simpleMessage(
      "Eng so‘nggi versiya o‘rnatilgan",
    ),
    "updateWindowsOnly": MessageLookupByLibrary.simpleMessage(
      "Avtomatik yangilash faqat Windows’da ishlaydi",
    ),
    "version": MessageLookupByLibrary.simpleMessage("Versiya"),
  };
}
