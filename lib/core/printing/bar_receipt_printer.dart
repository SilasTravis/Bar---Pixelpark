import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/sale/domain/bar_sale.dart';
import '../utils/money.dart';

enum ReceiptPrintResult {
  /// No printer is configured in Settings — printing is optional.
  skipped,
  printed,

  /// A printer is configured but the job failed (offline, removed, spooler
  /// error). The sale itself is fine; the cashier only gets a warning.
  failed,
}

/// Prints a bar sale on the 80mm receipt printer chosen in Settings.
/// Adapted from the cashier app's `SaleReceiptPrinter`, minus discounts,
/// split payments and balance.
class BarReceiptPrinter {
  BarReceiptPrinter({required this._printerName});

  /// The printer picked in Settings (`LocalSource.getReceiptPrinterName`),
  /// read on every print so a change applies to the very next sale.
  final String? Function() _printerName;

  static const double _paperWidthMm = 79;
  static const double _leftPaddingMm = 3;
  static const double _rightPaddingMm = 13;
  static const double _verticalPaddingMm = 10;
  static const double _contentWidthMm = 63;

  bool get isConfigured => _printerName() != null;

  /// Never throws.
  Future<ReceiptPrintResult> printSale(
    BarSale sale, {
    required String cashierName,
  }) async {
    final printerName = _printerName();
    if (printerName == null) return ReceiptPrintResult.skipped;
    try {
      final printers = await Printing.listPrinters();
      final target = printers
          .where((printer) => printer.name == printerName)
          .firstOrNull;
      if (target == null) {
        debugPrint('BarReceiptPrinter: printer "$printerName" not found');
        return ReceiptPrintResult.failed;
      }
      final printed = await Printing.directPrintPdf(
        printer: target,
        name: 'bar-sale-${sale.receiptNo}',
        format: _pageFormat(sale),
        usePrinterSettings: true,
        dynamicLayout: false,
        onLayout: (_) => buildPdf(sale, cashierName: cashierName),
      );
      return printed ? ReceiptPrintResult.printed : ReceiptPrintResult.failed;
    } catch (error) {
      debugPrint('BarReceiptPrinter: $error');
      return ReceiptPrintResult.failed;
    }
  }

  static PdfPageFormat _pageFormat(BarSale sale) => PdfPageFormat(
    _paperWidthMm * PdfPageFormat.mm,
    receiptHeightMm(sale) * PdfPageFormat.mm,
    marginAll: 0,
  );

  static Future<Uint8List> buildPdf(
    BarSale sale, {
    required String cashierName,
  }) async {
    final document = pw.Document();
    final pageFormat = PdfPageFormat(
      _paperWidthMm * PdfPageFormat.mm,
      receiptHeightMm(sale) * PdfPageFormat.mm,
      marginLeft: _leftPaddingMm * PdfPageFormat.mm,
      marginRight: _rightPaddingMm * PdfPageFormat.mm,
      marginTop: _verticalPaddingMm * PdfPageFormat.mm,
      marginBottom: _verticalPaddingMm * PdfPageFormat.mm,
    );
    final regular = pw.Font.helvetica();
    final bold = pw.Font.helveticaBold();

    document.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (_) => pw.Center(
          child: pw.SizedBox(
            width: _contentWidthMm * PdfPageFormat.mm,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Text(
                  printable(
                    sale.bar.name.isEmpty ? 'PIXEL BAR' : sale.bar.name,
                  ),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: bold, fontSize: 14),
                ),
                pw.SizedBox(height: 8),
                _textRow('Chek', '#${sale.receiptNo}', regular),
                _textRow(
                  'Sana',
                  DateFormat(
                    'dd.MM.yyyy HH:mm',
                  ).format(sale.createdAt.toLocal()),
                  regular,
                ),
                if (cashierName.isNotEmpty)
                  _textRow('Kassir', printable(cashierName), regular),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                for (final item in sale.items) ...[
                  pw.Text(
                    printable(item.name),
                    style: pw.TextStyle(font: regular, fontSize: 9),
                  ),
                  _textRow(
                    '${item.quantity} x ${formatUzs(item.priceUzs)}',
                    formatUzs(item.lineTotalUzs),
                    regular,
                  ),
                  pw.SizedBox(height: 4),
                ],
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                _textRow('JAMI', formatUzs(sale.totalUzs), bold, fontSize: 12),
                _textRow(
                  sale.paymentMethod == PaymentMethod.card ? 'Karta' : 'Naqd',
                  formatUzs(sale.totalUzs),
                  regular,
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  'Xaridingiz uchun rahmat!',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: regular, fontSize: 9),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return document.save();
  }

  /// The receipt uses the PDF built-in Helvetica (no bundled font), which
  /// only covers Latin-1. Uzbek apostrophes are folded to `'`; anything
  /// else outside Latin-1 (e.g. Cyrillic) becomes `?` instead of breaking
  /// the print job.
  @visibleForTesting
  static String printable(String text) {
    final folded = text.replaceAll(RegExp('[ʻʼ‘’`´]'), "'");
    return String.fromCharCodes(
      folded.runes.map((rune) => rune <= 0xFF ? rune : 0x3F),
    );
  }

  static pw.Widget _textRow(
    String label,
    String value,
    pw.Font font, {
    double fontSize = 9,
  }) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Text(
            label,
            style: pw.TextStyle(font: font, fontSize: fontSize),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(font: font, fontSize: fontSize),
          ),
        ),
      ],
    ),
  );

  @visibleForTesting
  static double receiptHeightMm(BarSale sale) {
    var height = 92.0;
    for (final item in sale.items) {
      final nameLines = (item.name.length / 28).ceil().clamp(1, 3);
      height += 11 + (nameLines - 1) * 5;
    }
    return height.clamp(100, 280).toDouble();
  }
}
