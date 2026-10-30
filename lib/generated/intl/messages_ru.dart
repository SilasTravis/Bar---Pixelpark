// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
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
  String get localeName => 'ru';

  static String m0(count) => "${count} шт.";

  static String m1(name, amount) =>
      "«${name}» — ${amount} будет удалён. Продолжить?";

  static String m2(name, amount) => "Расход сохранён: ${name} — ${amount}";

  static String m3(amount) => "Из кассы: ${amount}";

  static String m4(name, amount) =>
      "«${name}» — ${amount} будет удалён. Продолжить?";

  static String m5(name, amount) => "Приход сохранён: ${name} — ${amount}";

  static String m6(amount) => "В кассу: ${amount}";

  static String m7(cash, card) => "Н ${cash} · К ${card}";

  static String m8(total) => "Итого: ${total}";

  static String m9(name) => "${name} (сейчас не подключён)";

  static String m10(receiptNo) => "Чек #${receiptNo} отменён";

  static String m11(total) =>
      "Вся продажа будет отменена, ${total} исключится из выручки смены. Верните деньги покупателю.";

  static String m12(reason) => "Причина: ${reason}";

  static String m13(receiptNo) => "Отмена чека #${receiptNo}";

  static String m14(receiptNo, total) =>
      "Чек #${receiptNo} — продано на ${total}";

  static String m15(time) => "Смена с ${time}";

  static String m16(version) => "Доступна новая версия: ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "appTitle": MessageLookupByLibrary.simpleMessage("Pixel Bar"),
    "back": MessageLookupByLibrary.simpleMessage("Назад"),
    "barLabel": MessageLookupByLibrary.simpleMessage("Бар"),
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "cartClear": MessageLookupByLibrary.simpleMessage("Очистить"),
    "cartClearMessage": MessageLookupByLibrary.simpleMessage(
      "Все товары будут удалены из корзины. Продолжить?",
    ),
    "cartClearTitle": MessageLookupByLibrary.simpleMessage("Очистить корзину"),
    "cartEmpty": MessageLookupByLibrary.simpleMessage(
      "Корзина пуста — нажмите на товар, чтобы добавить",
    ),
    "cartItemsCount": m0,
    "cartTitle": MessageLookupByLibrary.simpleMessage("Корзина"),
    "cashDifference": MessageLookupByLibrary.simpleMessage("Разница"),
    "cashExpenses": MessageLookupByLibrary.simpleMessage("Расход из кассы"),
    "cashIncomes": MessageLookupByLibrary.simpleMessage("Приход в кассу"),
    "cashSales": MessageLookupByLibrary.simpleMessage("Наличные продажи"),
    "categoryAll": MessageLookupByLibrary.simpleMessage("Все"),
    "closeShift": MessageLookupByLibrary.simpleMessage("Закрыть смену"),
    "closeShiftConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "В закрытой смене нельзя продавать и отменять продажи.",
    ),
    "closeShiftConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Закрыть смену?",
    ),
    "countedCash": MessageLookupByLibrary.simpleMessage(
      "Наличные в кассе (пересчитано)",
    ),
    "countedCashHint": MessageLookupByLibrary.simpleMessage(
      "Пересчитайте наличные в кассе и введите сумму",
    ),
    "decrease": MessageLookupByLibrary.simpleMessage("Уменьшить"),
    "errorBarInactive": MessageLookupByLibrary.simpleMessage(
      "Этот бар неактивен. Обратитесь к администратору.",
    ),
    "errorCashierInactive": MessageLookupByLibrary.simpleMessage(
      "Ваш аккаунт неактивен. Обратитесь к администратору.",
    ),
    "errorEmptyCart": MessageLookupByLibrary.simpleMessage("Корзина пуста"),
    "errorExpenseNotFound": MessageLookupByLibrary.simpleMessage(
      "Расход не найден. Удалить можно только свой расход в открытой смене.",
    ),
    "errorIncomeNotFound": MessageLookupByLibrary.simpleMessage(
      "Приход не найден. Удалить можно только свой приход в открытой смене.",
    ),
    "errorInvalidPaymentSplit": MessageLookupByLibrary.simpleMessage(
      "Сумма наличных и карты не совпала с итогом. Введите смешанную оплату заново.",
    ),
    "errorNoInternet": MessageLookupByLibrary.simpleMessage(
      "Нет подключения к интернету. Проверьте соединение и повторите.",
    ),
    "errorProductUnavailable": MessageLookupByLibrary.simpleMessage(
      "Некоторые товары из корзины больше не продаются. Список обновлён — проверьте корзину и оплатите снова.",
    ),
    "errorSaleAlreadyRefunded": MessageLookupByLibrary.simpleMessage(
      "Эта продажа уже отменена",
    ),
    "errorSaleNotInShift": MessageLookupByLibrary.simpleMessage(
      "Отменить можно только продажу текущей открытой смены",
    ),
    "errorServer": MessageLookupByLibrary.simpleMessage(
      "Произошла ошибка сервера. Повторите чуть позже.",
    ),
    "errorShiftAlreadyOpen": MessageLookupByLibrary.simpleMessage(
      "Смена уже открыта",
    ),
    "errorShiftNotOpen": MessageLookupByLibrary.simpleMessage(
      "Смена не открыта. Сначала откройте смену.",
    ),
    "errorTooManyAttempts": MessageLookupByLibrary.simpleMessage(
      "Слишком много попыток. Повторите через минуту.",
    ),
    "errorUnknown": MessageLookupByLibrary.simpleMessage("Что-то пошло не так"),
    "expectedCash": MessageLookupByLibrary.simpleMessage("Ожидаемые наличные"),
    "expenseAmount": MessageLookupByLibrary.simpleMessage("Сумма"),
    "expenseAmountInvalid": MessageLookupByLibrary.simpleMessage(
      "Введите сумму (больше 0, не более 1 млрд)",
    ),
    "expenseDelete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "expenseDeleteConfirm": MessageLookupByLibrary.simpleMessage("Да, удалить"),
    "expenseDeleteMessage": m1,
    "expenseDeleteTitle": MessageLookupByLibrary.simpleMessage(
      "Удалить расход",
    ),
    "expenseDeleted": MessageLookupByLibrary.simpleMessage("Расход удалён"),
    "expenseName": MessageLookupByLibrary.simpleMessage("Название"),
    "expenseNameHint": MessageLookupByLibrary.simpleMessage("Например: Молоко"),
    "expenseNameRequired": MessageLookupByLibrary.simpleMessage(
      "Введите название",
    ),
    "expenseNew": MessageLookupByLibrary.simpleMessage("Новый расход"),
    "expensePaidFrom": MessageLookupByLibrary.simpleMessage("Откуда оплачено"),
    "expenseQuickPick": MessageLookupByLibrary.simpleMessage("Быстрый выбор"),
    "expenseSave": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "expenseSaved": m2,
    "expensesEmpty": MessageLookupByLibrary.simpleMessage(
      "В этой смене ещё нет расходов",
    ),
    "expensesEmptyHint": MessageLookupByLibrary.simpleMessage(
      "Запишите расход из кассы или из другого источника через «Новый расход»",
    ),
    "expensesFromCashTotal": m3,
    "expensesShiftTotal": MessageLookupByLibrary.simpleMessage("РАСХОДЫ СМЕНЫ"),
    "expensesTitle": MessageLookupByLibrary.simpleMessage("Расходы"),
    "historyEmpty": MessageLookupByLibrary.simpleMessage(
      "В этой смене ещё нет продаж",
    ),
    "historyTitle": MessageLookupByLibrary.simpleMessage("История смены"),
    "incomeAmount": MessageLookupByLibrary.simpleMessage("Сумма"),
    "incomeAmountInvalid": MessageLookupByLibrary.simpleMessage(
      "Введите сумму (больше 0, не более 1 млрд)",
    ),
    "incomeDelete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "incomeDeleteConfirm": MessageLookupByLibrary.simpleMessage("Да, удалить"),
    "incomeDeleteMessage": m4,
    "incomeDeleteTitle": MessageLookupByLibrary.simpleMessage("Удалить приход"),
    "incomeDeleted": MessageLookupByLibrary.simpleMessage("Приход удалён"),
    "incomeName": MessageLookupByLibrary.simpleMessage("Название"),
    "incomeNameHint": MessageLookupByLibrary.simpleMessage("Например: Депозит"),
    "incomeNameRequired": MessageLookupByLibrary.simpleMessage(
      "Введите название",
    ),
    "incomeNew": MessageLookupByLibrary.simpleMessage("Новый приход"),
    "incomeQuickPick": MessageLookupByLibrary.simpleMessage("Быстрый выбор"),
    "incomeReceivedTo": MessageLookupByLibrary.simpleMessage("Куда поступило"),
    "incomeSave": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "incomeSaved": m5,
    "incomesEmpty": MessageLookupByLibrary.simpleMessage(
      "В этой смене ещё нет приходов",
    ),
    "incomesEmptyHint": MessageLookupByLibrary.simpleMessage(
      "Запишите деньги, поступившие в кассу или в другое место, через «Новый приход»",
    ),
    "incomesFromCashTotal": m6,
    "incomesShiftTotal": MessageLookupByLibrary.simpleMessage("ПРИХОДЫ СМЕНЫ"),
    "incomesTitle": MessageLookupByLibrary.simpleMessage("Приходы"),
    "increase": MessageLookupByLibrary.simpleMessage("Увеличить"),
    "language": MessageLookupByLibrary.simpleMessage("Язык"),
    "languageRussian": MessageLookupByLibrary.simpleMessage("Русский"),
    "languageUzbek": MessageLookupByLibrary.simpleMessage("O‘zbekcha"),
    "loginButton": MessageLookupByLibrary.simpleMessage("Войти"),
    "loginInvalid": MessageLookupByLibrary.simpleMessage(
      "Неверный логин или пароль",
    ),
    "loginPassword": MessageLookupByLibrary.simpleMessage("Пароль"),
    "loginShowPassword": MessageLookupByLibrary.simpleMessage(
      "Показать пароль",
    ),
    "loginSubtitle": MessageLookupByLibrary.simpleMessage(
      "Введите логин и пароль для входа в кассу бара",
    ),
    "loginUsername": MessageLookupByLibrary.simpleMessage("Логин"),
    "logout": MessageLookupByLibrary.simpleMessage("Выйти"),
    "logoutConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "Выйти из аккаунта? Открытая смена останется открытой на сервере и продолжится при следующем входе.",
    ),
    "logoutConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Выход из системы",
    ),
    "menu": MessageLookupByLibrary.simpleMessage("Меню"),
    "menuCloseShift": MessageLookupByLibrary.simpleMessage("Закрыть смену"),
    "menuExpenses": MessageLookupByLibrary.simpleMessage("Расходы"),
    "menuHistory": MessageLookupByLibrary.simpleMessage("История смены"),
    "menuIncomes": MessageLookupByLibrary.simpleMessage("Приходы"),
    "menuSettings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "mixedInvalid": MessageLookupByLibrary.simpleMessage(
      "Наличные и карта вместе должны равняться сумме",
    ),
    "mixedPay": MessageLookupByLibrary.simpleMessage("Оплатить"),
    "mixedSplitShort": m7,
    "mixedTitle": MessageLookupByLibrary.simpleMessage("Смешанная оплата"),
    "mixedTotal": m8,
    "noOpenShiftMessage": MessageLookupByLibrary.simpleMessage(
      "Откройте смену, чтобы начать продажи",
    ),
    "noOpenShiftTitle": MessageLookupByLibrary.simpleMessage(
      "Смена не открыта",
    ),
    "noPrintersFound": MessageLookupByLibrary.simpleMessage(
      "На компьютере не найдено установленных принтеров",
    ),
    "noteOptional": MessageLookupByLibrary.simpleMessage(
      "Комментарий (необязательно)",
    ),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "openShift": MessageLookupByLibrary.simpleMessage("Открыть смену"),
    "paidFromCash": MessageLookupByLibrary.simpleMessage("Из кассы"),
    "paidFromOther": MessageLookupByLibrary.simpleMessage("Другое"),
    "paymentCard": MessageLookupByLibrary.simpleMessage("Карта"),
    "paymentCash": MessageLookupByLibrary.simpleMessage("Наличные"),
    "paymentMixed": MessageLookupByLibrary.simpleMessage("Смешанная"),
    "printerHint": MessageLookupByLibrary.simpleMessage(
      "Если выбран принтер, чек печатается автоматически после каждой продажи.",
    ),
    "printerNone": MessageLookupByLibrary.simpleMessage(
      "Без принтера (чек не печатается)",
    ),
    "printerSettings": MessageLookupByLibrary.simpleMessage("Принтер чеков"),
    "printerUnavailable": m9,
    "productsEmpty": MessageLookupByLibrary.simpleMessage(
      "В этом баре пока нет активных товаров",
    ),
    "receiptCashier": MessageLookupByLibrary.simpleMessage("Кассир"),
    "receiptCheckNo": MessageLookupByLibrary.simpleMessage("Чек №"),
    "receiptCurrency": MessageLookupByLibrary.simpleMessage("сум"),
    "receiptDate": MessageLookupByLibrary.simpleMessage("Дата"),
    "receiptPaymentMethod": MessageLookupByLibrary.simpleMessage(
      "Способ оплаты",
    ),
    "receiptPrintFailed": MessageLookupByLibrary.simpleMessage(
      "Продажа сохранена, но чек не напечатан. Проверьте принтер.",
    ),
    "receiptPrinter": MessageLookupByLibrary.simpleMessage("Принтер"),
    "receiptRefunded": MessageLookupByLibrary.simpleMessage("ЧЕК ОТМЕНЁН"),
    "receiptThanks": MessageLookupByLibrary.simpleMessage(
      "Спасибо за покупку!",
    ),
    "receiptTotal": MessageLookupByLibrary.simpleMessage("ИТОГО"),
    "receiptsCount": MessageLookupByLibrary.simpleMessage("Чеки"),
    "receivedToCash": MessageLookupByLibrary.simpleMessage("В кассу"),
    "receivedToOther": MessageLookupByLibrary.simpleMessage("Другое"),
    "refresh": MessageLookupByLibrary.simpleMessage("Обновить"),
    "refreshProducts": MessageLookupByLibrary.simpleMessage("Обновить товары"),
    "refund": MessageLookupByLibrary.simpleMessage("Отменить"),
    "refundConfirm": MessageLookupByLibrary.simpleMessage("Да, отменить"),
    "refundDone": m10,
    "refundMessage": m11,
    "refundReasonOptional": MessageLookupByLibrary.simpleMessage(
      "Причина (необязательно)",
    ),
    "refundReasonShown": m12,
    "refundTitle": m13,
    "refundedCount": MessageLookupByLibrary.simpleMessage("Отменённые"),
    "removeLine": MessageLookupByLibrary.simpleMessage("Удалить"),
    "retry": MessageLookupByLibrary.simpleMessage("Повторить"),
    "saleCompleted": m14,
    "saleErrorNetwork": MessageLookupByLibrary.simpleMessage(
      "Нет подключения к интернету. Корзина сохранена — нажмите кнопку оплаты ещё раз, двойного списания не будет.",
    ),
    "saleErrorServer": MessageLookupByLibrary.simpleMessage(
      "Ошибка сервера. Корзина сохранена — повторите, продажа не задвоится.",
    ),
    "saleErrorUnknownOutcome": MessageLookupByLibrary.simpleMessage(
      "Не удалось прочитать ответ сервера. Корзина сохранена — повторите, продажа не задвоится.",
    ),
    "shiftClosedTitle": MessageLookupByLibrary.simpleMessage("Смена закрыта"),
    "shiftExpenses": MessageLookupByLibrary.simpleMessage("Расходы"),
    "shiftIncomes": MessageLookupByLibrary.simpleMessage("Приходы"),
    "shiftOpenedAt": m15,
    "shiftPeriod": MessageLookupByLibrary.simpleMessage("Время смены"),
    "shiftRevenue": MessageLookupByLibrary.simpleMessage("ВЫРУЧКА СМЕНЫ"),
    "statusRefunded": MessageLookupByLibrary.simpleMessage("Отменён"),
    "total": MessageLookupByLibrary.simpleMessage("Итого"),
    "updateAvailable": m16,
    "updateCancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "updateCheck": MessageLookupByLibrary.simpleMessage("Проверить обновления"),
    "updateConfirm": MessageLookupByLibrary.simpleMessage("Продолжить"),
    "updateConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "Приложение закроется и откроется в новой версии. Смена останется открытой. Продолжить?",
    ),
    "updateConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Обновление приложения",
    ),
    "updateDownload": MessageLookupByLibrary.simpleMessage(
      "Скачать и установить",
    ),
    "updateDownloading": MessageLookupByLibrary.simpleMessage("Загрузка…"),
    "updateFailed": MessageLookupByLibrary.simpleMessage("Не удалось обновить"),
    "updateFailedGeneric": MessageLookupByLibrary.simpleMessage(
      "Не удалось обновить. Проверьте интернет и попробуйте ещё раз.",
    ),
    "updateFailureChecksumMismatch": MessageLookupByLibrary.simpleMessage(
      "Загруженный файл повреждён — контрольная сумма не совпала",
    ),
    "updateFailureChecksumUnreadable": MessageLookupByLibrary.simpleMessage(
      "Не удалось прочитать опубликованную контрольную сумму — непроверенное обновление не устанавливается",
    ),
    "updateFailureExecutableMissing": MessageLookupByLibrary.simpleMessage(
      "В загруженном архиве не найден исполняемый файл приложения",
    ),
    "updateFailureIncompleteExtraction": MessageLookupByLibrary.simpleMessage(
      "Обновление распаковано не полностью. Загрузка удалена — попробуйте ещё раз",
    ),
    "updateManualHint": MessageLookupByLibrary.simpleMessage(
      "Скачать вручную:",
    ),
    "updateReady": MessageLookupByLibrary.simpleMessage("Обновление готово"),
    "updateRestart": MessageLookupByLibrary.simpleMessage("Перезапустить"),
    "updateTitle": MessageLookupByLibrary.simpleMessage("Обновление"),
    "updateUpToDate": MessageLookupByLibrary.simpleMessage(
      "Установлена последняя версия",
    ),
    "updateWindowsOnly": MessageLookupByLibrary.simpleMessage(
      "Автообновление работает только в Windows",
    ),
    "version": MessageLookupByLibrary.simpleMessage("Версия"),
  };
}
