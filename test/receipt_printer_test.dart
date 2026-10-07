import 'dart:ui';

import 'package:bar_app/core/printing/bar_receipt_printer.dart';
import 'package:bar_app/features/sale/domain/bar_sale.dart';
import 'package:bar_app/generated/l10n.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fixtures.dart';

BarSale _saleWith(
  List<BarSaleItem> items, {
  PaymentMethod method = PaymentMethod.cash,
  SaleStatus status = SaleStatus.completed,
}) {
  final base = saleFixture(status: status);
  final total = items.fold<int>(0, (sum, item) => sum + item.lineTotalUzs);
  return BarSale(
    id: base.id,
    receiptNo: base.receiptNo,
    bar: base.bar,
    shiftId: base.shiftId,
    cashierId: base.cashierId,
    cashierName: base.cashierName,
    paymentMethod: method,
    totalUzs: total,
    cashUzs: method == PaymentMethod.card ? 0 : total,
    cardUzs: method == PaymentMethod.card ? total : 0,
    status: status,
    createdAt: base.createdAt,
    items: items,
  );
}

BarSaleItem _item(String name, {int price = 12000, int quantity = 1}) =>
    BarSaleItem(
      productId: name,
      name: name,
      priceUzs: price,
      quantity: quantity,
      lineTotalUzs: price * quantity,
    );

Future<ReceiptStrings> _strings(String languageCode) async {
  await AppLocalization.load(Locale(languageCode));
  return ReceiptStrings.of(AppLocalization.current);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ReceiptStrings uz;

  setUp(() async => uz = await _strings('uz'));

  Future<RenderedReceipt> render(BarSale sale, [ReceiptStrings? strings]) =>
      BarReceiptPrinter.render(
        sale,
        cashierName: 'Aziz',
        strings: strings ?? uz,
      );

  test('builds a PDF with the bundled font embedded', () async {
    final receipt = await render(saleFixture());
    expect(String.fromCharCodes(receipt.bytes.take(5)), '%PDF-');
    expect(String.fromCharCodes(receipt.bytes), contains('Roboto'));
  });

  test('page height follows the content: no blank tail, no clipping', () async {
    final one = await render(saleFixture());
    // Header + meta + one item + total + footer + 10mm cutter feed.
    expect(one.heightMm, inInclusiveRange(90, 140));

    final twelve = await render(
      _saleWith([for (var i = 0; i < 12; i++) _item('Mahsulot $i')]),
    );
    final perItem = (twelve.heightMm - one.heightMm) / 11;
    expect(perItem, inInclusiveRange(7, 12));

    final longNames = await render(
      _saleWith([
        for (var i = 0; i < 12; i++)
          _item('Juda uzun mahsulot nomi ikki qatorga oʻraladi, $i-raqam'),
      ]),
    );
    expect(longNames.heightMm, greaterThan(twelve.heightMm + 30));

    // A name never takes more than two lines.
    final huge = await render(_saleWith([_item('Nom ' * 200)]));
    final wrapped = await render(
      _saleWith([_item('Juda uzun mahsulot nomi ikki qatorga oʻraladi, 1')]),
    );
    expect(huge.heightMm, closeTo(wrapped.heightMm, 0.5));
  });

  test('a split and a refunded reprint add their rows', () async {
    final cash = await render(saleFixture(totalUzs: 44000));
    final mixed = await render(
      saleFixture(method: PaymentMethod.mixed, totalUzs: 44000, cashUzs: 30000),
    );
    final refunded = await render(saleFixture(status: SaleStatus.refunded));
    expect(mixed.heightMm, greaterThan(cash.heightMm + 6));
    expect(refunded.heightMm, greaterThan(cash.heightMm + 5));
  });

  test('Uzbek apostrophes and Cyrillic print as real glyphs', () async {
    expect(BarReceiptPrinter.printable('Oʻrik, gʻisht'), 'O‘rik, g‘isht');
    expect(BarReceiptPrinter.printable('Choyxo‘ra oʼ'), 'Choyxo‘ra oʼ');
    expect(BarReceiptPrinter.printable('Кофе латте'), 'Кофе латте');

    final ru = await _strings('ru');
    expect(ru.total, 'ИТОГО');
    expect(ru.thanks, 'Спасибо за покупку!');
    final receipt = await BarReceiptPrinter.render(
      _saleWith([_item('Чай чёрный с лимоном')]),
      cashierName: 'Азиз',
      strings: ru,
    );
    expect(String.fromCharCodes(receipt.bytes.take(5)), '%PDF-');
  });

  test('payment lines: one for cash/card, both parts for a split', () {
    expect(BarReceiptPrinter.paymentLines(saleFixture(totalUzs: 24000), uz), [
      ('Naqd', '24 000'),
    ]);
    final card = saleFixture(method: PaymentMethod.card, totalUzs: 24000);
    expect(BarReceiptPrinter.paymentLines(card, uz), [('Karta', '24 000')]);
    expect(BarReceiptPrinter.methodLabel(card, uz), 'Karta');
    final mixed = saleFixture(
      method: PaymentMethod.mixed,
      totalUzs: 44000,
      cashUzs: 30000,
    );
    expect(BarReceiptPrinter.methodLabel(mixed, uz), 'Aralash');
    expect(BarReceiptPrinter.paymentLines(mixed, uz), [
      ('Naqd', '30 000'),
      ('Karta', '14 000'),
    ]);
  });

  test('date and time are digits only, in local time', () {
    final value = DateTime(2026, 10, 7, 9, 5);
    expect(BarReceiptPrinter.formatDateTime(value), '07.10.2026  09:05');
  });
}
