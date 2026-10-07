import 'package:bar_app/core/printing/bar_receipt_printer.dart';
import 'package:bar_app/features/sale/domain/bar_sale.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fixtures.dart';

void main() {
  test('builds a PDF for a sale', () async {
    final bytes = await BarReceiptPrinter.buildPdf(
      saleFixture(),
      cashierName: 'Aziz',
    );
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('non Latin-1 text never breaks the receipt', () async {
    expect(BarReceiptPrinter.printable("Choyxo‘ra ʻoʼ"), "Choyxo'ra 'o'");
    expect(BarReceiptPrinter.printable('Кофе'), '????');
    final bytes = await BarReceiptPrinter.buildPdf(
      saleFixture(),
      cashierName: 'Азиз',
    );
    expect(bytes, isNotEmpty);
  });

  test('payment lines: one for cash/card, both parts for a split', () async {
    expect(BarReceiptPrinter.paymentLines(saleFixture(totalUzs: 24000)), [
      ('Naqd', "24 000 so'm"),
    ]);
    expect(
      BarReceiptPrinter.paymentLines(
        saleFixture(method: PaymentMethod.card, totalUzs: 24000),
      ),
      [('Karta', "24 000 so'm")],
    );
    final mixed = saleFixture(
      method: PaymentMethod.mixed,
      totalUzs: 44000,
      cashUzs: 30000,
    );
    expect(BarReceiptPrinter.paymentLines(mixed), [
      ('Naqd', "30 000 so'm"),
      ('Karta', "14 000 so'm"),
    ]);
    expect(
      BarReceiptPrinter.receiptHeightMm(mixed),
      greaterThan(BarReceiptPrinter.receiptHeightMm(saleFixture())),
    );
    final bytes = await BarReceiptPrinter.buildPdf(mixed, cashierName: 'Aziz');
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
