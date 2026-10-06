import 'package:bar_app/core/printing/bar_receipt_printer.dart';
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
}
