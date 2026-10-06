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

  static String m1(name) => "${name} (сейчас не подключён)";

  static String m2(receiptNo) => "Чек #${receiptNo} отменён";

  static String m3(total) =>
      "Вся продажа будет отменена, ${total} исключится из выручки смены. Верните деньги покупателю.";

  static String m4(reason) => "Причина: ${reason}";

  static String m5(receiptNo) => "Отмена чека #${receiptNo}";

  static String m6(receiptNo, total) =>
      "Чек #${receiptNo} — продано на ${total}";

  static String m7(time) => "Смена с ${time}";

  static String m8(version) => "Доступна новая версия: ${version}";

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
    "historyEmpty": MessageLookupByLibrary.simpleMessage(
      "В этой смене ещё нет продаж",
    ),
    "historyTitle": MessageLookupByLibrary.simpleMessage("История смены"),
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
    "menuHistory": MessageLookupByLibrary.simpleMessage("История смены"),
    "menuSettings": MessageLookupByLibrary.simpleMessage("Настройки"),
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
    "paymentCard": MessageLookupByLibrary.simpleMessage("Карта"),
    "paymentCash": MessageLookupByLibrary.simpleMessage("Наличные"),
    "printerHint": MessageLookupByLibrary.simpleMessage(
      "Если выбран принтер, чек печатается автоматически после каждой продажи.",
    ),
    "printerNone": MessageLookupByLibrary.simpleMessage(
      "Без принтера (чек не печатается)",
    ),
    "printerSettings": MessageLookupByLibrary.simpleMessage("Принтер чеков"),
    "printerUnavailable": m1,
    "productsEmpty": MessageLookupByLibrary.simpleMessage(
      "В этом баре пока нет активных товаров",
    ),
    "receiptPrintFailed": MessageLookupByLibrary.simpleMessage(
      "Продажа сохранена, но чек не напечатан. Проверьте принтер.",
    ),
    "receiptPrinter": MessageLookupByLibrary.simpleMessage("Принтер"),
    "receiptsCount": MessageLookupByLibrary.simpleMessage("Чеки"),
    "refresh": MessageLookupByLibrary.simpleMessage("Обновить"),
    "refreshProducts": MessageLookupByLibrary.simpleMessage("Обновить товары"),
    "refund": MessageLookupByLibrary.simpleMessage("Отменить"),
    "refundConfirm": MessageLookupByLibrary.simpleMessage("Да, отменить"),
    "refundDone": m2,
    "refundMessage": m3,
    "refundReasonOptional": MessageLookupByLibrary.simpleMessage(
      "Причина (необязательно)",
    ),
    "refundReasonShown": m4,
    "refundTitle": m5,
    "refundedCount": MessageLookupByLibrary.simpleMessage("Отменённые"),
    "removeLine": MessageLookupByLibrary.simpleMessage("Удалить"),
    "retry": MessageLookupByLibrary.simpleMessage("Повторить"),
    "saleCompleted": m6,
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
    "shiftOpenedAt": m7,
    "shiftPeriod": MessageLookupByLibrary.simpleMessage("Время смены"),
    "shiftRevenue": MessageLookupByLibrary.simpleMessage("ВЫРУЧКА СМЕНЫ"),
    "statusRefunded": MessageLookupByLibrary.simpleMessage("Отменён"),
    "total": MessageLookupByLibrary.simpleMessage("Итого"),
    "updateAvailable": m8,
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
