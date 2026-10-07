import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/sale/domain/bar_sale.dart';
import '../../generated/l10n.dart';
import '../utils/money.dart';

enum ReceiptPrintResult {
  /// No printer is configured in Settings — printing is optional.
  skipped,
  printed,

  /// A printer is configured but the job failed (offline, removed, spooler
  /// error). The sale itself is fine; the cashier only gets a warning.
  failed,
}

/// The receipt's words in the app's current language (uz / ru). Captured
/// synchronously from [AppLocalization] when the sale completes — `Intl`
/// reads the global locale, so it must not be read later inside the async
/// print job.
class ReceiptStrings {
  const ReceiptStrings({
    required this.checkNo,
    required this.date,
    required this.cashier,
    required this.total,
    required this.paymentMethod,
    required this.cash,
    required this.card,
    required this.mixed,
    required this.currency,
    required this.thanks,
    required this.refunded,
  });

  factory ReceiptStrings.of(AppLocalization l10n) => ReceiptStrings(
    checkNo: l10n.receiptCheckNo,
    date: l10n.receiptDate,
    cashier: l10n.receiptCashier,
    total: l10n.receiptTotal,
    paymentMethod: l10n.receiptPaymentMethod,
    cash: l10n.paymentCash,
    card: l10n.paymentCard,
    mixed: l10n.paymentMixed,
    currency: l10n.receiptCurrency,
    thanks: l10n.receiptThanks,
    refunded: l10n.receiptRefunded,
  );

  final String checkNo;
  final String date;
  final String cashier;
  final String total;
  final String paymentMethod;
  final String cash;
  final String card;
  final String mixed;
  final String currency;
  final String thanks;
  final String refunded;
}

/// The bundled receipt font (Roboto, Apache-2.0 — `assets/fonts`). Unlike
/// the PDF built-in Helvetica it covers Cyrillic and the Uzbek apostrophes,
/// and its digits are tabular, so amounts line up column-wise.
class ReceiptFonts {
  const ReceiptFonts({
    required this.regular,
    required this.bold,
    required this.black,
  });

  final pw.Font regular;
  final pw.Font bold;
  final pw.Font black;

  static Future<ReceiptFonts>? _cached;

  /// Loaded once per process; a failed load is retried on the next print.
  static Future<ReceiptFonts> load() {
    final cached = _cached;
    if (cached != null) return cached;
    final future = _load();
    _cached = future;
    future.then<void>(
      (_) {},
      onError: (Object _) {
        if (identical(_cached, future)) _cached = null;
      },
    );
    return future;
  }

  static Future<ReceiptFonts> _load() async {
    Future<pw.Font> font(String name) async =>
        pw.Font.ttf(await rootBundle.load('assets/fonts/$name.ttf'));
    return ReceiptFonts(
      regular: await font('Roboto-Regular'),
      bold: await font('Roboto-Bold'),
      black: await font('Roboto-Black'),
    );
  }
}

/// A laid-out receipt: the PDF and its exact page height, so the print job
/// feeds exactly the content (plus the cutter margin) — no blank tail and
/// nothing clipped, however many lines the sale has.
class RenderedReceipt {
  const RenderedReceipt({required this.bytes, required this.heightMm});

  final Uint8List bytes;
  final double heightMm;
}

/// Prints a bar sale on the 80mm receipt printer chosen in Settings.
///
/// Same print path and page geometry as the park cashier's
/// `SaleReceiptPrinter` (79mm page, 63mm content shifted left for the SLK
/// heads, `directPrintPdf` with the printer's own settings), so Windows
/// thermal tills behave the same — only the layout and the font differ.
class BarReceiptPrinter {
  BarReceiptPrinter({required this._printerName});

  /// The printer picked in Settings (`LocalSource.getReceiptPrinterName`),
  /// read on every print so a change applies to the very next sale.
  final String? Function() _printerName;

  static const double _paperWidthMm = 79;
  static const double _leftPaddingMm = 3;
  static const double _rightPaddingMm = 13;
  static const double _topPaddingMm = 4;

  /// Blank paper after the footer so the cutter never slices the text.
  static const double _bottomFeedMm = 10;

  bool get isConfigured => _printerName() != null;

  /// Never throws.
  Future<ReceiptPrintResult> printSale(
    BarSale sale, {
    required String cashierName,
    required ReceiptStrings strings,
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
      final receipt = await render(
        sale,
        cashierName: cashierName,
        strings: strings,
      );
      final printed = await Printing.directPrintPdf(
        printer: target,
        name: 'bar-sale-${sale.receiptNo}',
        format: PdfPageFormat(
          _paperWidthMm * PdfPageFormat.mm,
          receipt.heightMm * PdfPageFormat.mm,
          marginAll: 0,
        ),
        usePrinterSettings: true,
        dynamicLayout: false,
        onLayout: (_) async => receipt.bytes,
      );
      return printed ? ReceiptPrintResult.printed : ReceiptPrintResult.failed;
    } catch (error) {
      debugPrint('BarReceiptPrinter: $error');
      return ReceiptPrintResult.failed;
    }
  }

  /// Lays the receipt out on an endless 80mm roll; the page then takes the
  /// content's height, which is what [RenderedReceipt.heightMm] reports.
  static Future<RenderedReceipt> render(
    BarSale sale, {
    required String cashierName,
    required ReceiptStrings strings,
  }) async {
    final fonts = await ReceiptFonts.load();
    final document = pw.Document(
      title: 'Chek #${sale.receiptNo}',
      theme: pw.ThemeData.withFont(
        base: fonts.regular,
        bold: fonts.bold,
      ).copyWith(defaultTextStyle: _style(fonts.regular, 9)),
    );
    document.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          _paperWidthMm * PdfPageFormat.mm,
          double.infinity,
          marginLeft: _leftPaddingMm * PdfPageFormat.mm,
          marginRight: _rightPaddingMm * PdfPageFormat.mm,
          marginTop: _topPaddingMm * PdfPageFormat.mm,
          marginBottom: _bottomFeedMm * PdfPageFormat.mm,
        ),
        build: (_) => _ReceiptLayout(
          sale: sale,
          cashierName: cashierName,
          strings: strings,
          fonts: fonts,
        ).build(),
      ),
    );
    final bytes = await document.save();
    final heightPt =
        document.document.pdfPageList.pages.first.pageFormat.height;
    return RenderedReceipt(bytes: bytes, heightMm: heightPt / PdfPageFormat.mm);
  }

  /// The PDF only (tests, previews).
  static Future<Uint8List> buildPdf(
    BarSale sale, {
    required String cashierName,
    required ReceiptStrings strings,
  }) async =>
      (await render(sale, cashierName: cashierName, strings: strings)).bytes;

  /// Roboto has no U+02BB (ʻ, the Uzbek oʻ / gʻ letter); U+2018 is the same
  /// turned-comma shape, so the name still reads right instead of printing
  /// a missing-glyph box. Everything else, Cyrillic included, prints as is.
  @visibleForTesting
  static String printable(String text) => text.replaceAll('ʻ', '‘');

  /// `07.10.2026  14:42` in the till's local time (Tashkent), like the rest
  /// of the app. Digits only, so it needs no `intl` locale data.
  @visibleForTesting
  static String formatDateTime(DateTime value) {
    final local = value.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}.${two(local.month)}.${local.year}  '
        '${two(local.hour)}:${two(local.minute)}';
  }

  /// The receipt's payment lines (label, amount): one for a cash or card
  /// sale, both parts for a split.
  @visibleForTesting
  static List<(String, String)> paymentLines(
    BarSale sale,
    ReceiptStrings strings,
  ) => switch (sale.paymentMethod) {
    PaymentMethod.cash => [(strings.cash, groupThousands(sale.totalUzs))],
    PaymentMethod.card => [(strings.card, groupThousands(sale.totalUzs))],
    PaymentMethod.mixed => [
      (strings.cash, groupThousands(sale.cashUzs)),
      (strings.card, groupThousands(sale.cardUzs)),
    ],
  };

  static String methodLabel(BarSale sale, ReceiptStrings strings) =>
      switch (sale.paymentMethod) {
        PaymentMethod.cash => strings.cash,
        PaymentMethod.card => strings.card,
        PaymentMethod.mixed => strings.mixed,
      };
}

pw.TextStyle _style(
  pw.Font font,
  double size, {
  double letterSpacing = 0,
  PdfColor color = PdfColors.black,
}) => pw.TextStyle(
  font: font,
  fontSize: size,
  letterSpacing: letterSpacing,
  color: color,
  lineSpacing: 1,
);

/// The receipt's widget tree: black only, 63mm wide, sized for a 203dpi
/// thermal head (nothing thinner than ~2 dots, nothing smaller than 8pt).
class _ReceiptLayout {
  _ReceiptLayout({
    required this.sale,
    required this.cashierName,
    required this.strings,
    required this.fonts,
  });

  final BarSale sale;
  final String cashierName;
  final ReceiptStrings strings;
  final ReceiptFonts fonts;

  static String _t(String text) => BarReceiptPrinter.printable(text);

  pw.Widget build() => pw.Column(
    mainAxisSize: pw.MainAxisSize.min,
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      ..._header(),
      if (sale.isRefunded) ...[pw.SizedBox(height: 8), _refundedBanner()],
      pw.SizedBox(height: 10),
      _DashedRule(),
      pw.SizedBox(height: 8),
      ..._meta(),
      pw.SizedBox(height: 8),
      _DashedRule(),
      pw.SizedBox(height: 8),
      ..._items(),
      pw.SizedBox(height: 7),
      _DashedRule(),
      pw.SizedBox(height: 8),
      _total(),
      pw.SizedBox(height: 7),
      ..._payment(),
      pw.SizedBox(height: 10),
      _DashedRule(),
      pw.SizedBox(height: 10),
      ..._footer(),
    ],
  );

  List<pw.Widget> _header() {
    final barName = _t(sale.bar.name.trim());
    return [
      _PixelStrip(),
      pw.SizedBox(height: 9),
      // Letter spacing also trails the last letter; the same inset on the
      // left keeps the wordmark optically centred.
      pw.Padding(
        padding: const pw.EdgeInsets.only(left: 2.5),
        child: pw.Text(
          'PIXEL BAR',
          textAlign: pw.TextAlign.center,
          style: _style(fonts.black, 24, letterSpacing: 2.5),
        ),
      ),
      if (barName.isNotEmpty && barName.toUpperCase() != 'PIXEL BAR') ...[
        pw.SizedBox(height: 3),
        pw.Text(
          barName,
          textAlign: pw.TextAlign.center,
          maxLines: 2,
          style: _style(fonts.bold, 10.5),
        ),
      ],
    ];
  }

  pw.Widget _refundedBanner() => pw.Container(
    color: PdfColors.black,
    padding: const pw.EdgeInsets.fromLTRB(7.5, 4, 6, 4),
    child: pw.Text(
      _t(strings.refunded),
      textAlign: pw.TextAlign.center,
      style: _style(
        fonts.black,
        13,
        letterSpacing: 1.5,
        color: PdfColors.white,
      ),
    ),
  );

  List<pw.Widget> _meta() => [
    _row(
      pw.Text(_t(strings.checkNo), style: _style(fonts.bold, 10)),
      pw.Text('${sale.receiptNo}', style: _style(fonts.black, 15)),
    ),
    pw.SizedBox(height: 4),
    _row(
      pw.Text(_t(strings.date), style: _style(fonts.regular, 9)),
      pw.Text(
        BarReceiptPrinter.formatDateTime(sale.createdAt),
        style: _style(fonts.bold, 9),
      ),
    ),
    if (cashierName.trim().isNotEmpty) ...[
      pw.SizedBox(height: 3),
      _row(
        pw.Text(_t(strings.cashier), style: _style(fonts.regular, 9)),
        pw.Text(
          _t(cashierName.trim()),
          textAlign: pw.TextAlign.right,
          maxLines: 2,
          style: _style(fonts.bold, 9),
        ),
        valueFlex: 3,
        alignTop: true,
      ),
    ],
  ];

  List<pw.Widget> _items() => [
    for (final (index, item) in sale.items.indexed) ...[
      if (index > 0) pw.SizedBox(height: 6),
      pw.Text(_t(item.name), maxLines: 2, style: _style(fonts.bold, 10)),
      pw.SizedBox(height: 1.5),
      _row(
        pw.Text(
          '${item.quantity} × ${groupThousands(item.priceUzs)}',
          style: _style(fonts.regular, 9),
        ),
        pw.Text(
          groupThousands(item.lineTotalUzs),
          style: _style(fonts.bold, 10),
        ),
      ),
    ],
  ];

  pw.Widget _total() => pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      pw.Text(_t(strings.total), style: _style(fonts.black, 17)),
      pw.SizedBox(width: 8),
      pw.Expanded(
        child: pw.RichText(
          textAlign: pw.TextAlign.right,
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: groupThousands(sale.totalUzs),
                style: _style(fonts.black, 17),
              ),
              pw.TextSpan(
                text: ' ${_t(strings.currency)}',
                style: _style(fonts.bold, 10),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  List<pw.Widget> _payment() => [
    _row(
      pw.Text(_t(strings.paymentMethod), style: _style(fonts.regular, 9)),
      pw.Text(
        _t(BarReceiptPrinter.methodLabel(sale, strings)),
        style: _style(fonts.bold, 10),
      ),
    ),
    if (sale.isMixed)
      for (final (label, amount) in BarReceiptPrinter.paymentLines(
        sale,
        strings,
      )) ...[
        pw.SizedBox(height: 3),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 10),
          child: _row(
            pw.Text(_t(label), style: _style(fonts.regular, 9)),
            pw.Text(amount, style: _style(fonts.bold, 9)),
          ),
        ),
      ],
  ];

  List<pw.Widget> _footer() => [
    pw.Text(
      _t(strings.thanks),
      textAlign: pw.TextAlign.center,
      style: _style(fonts.bold, 11),
    ),
    pw.SizedBox(height: 4),
    pw.Text(
      'P I X E L   P A R K',
      textAlign: pw.TextAlign.center,
      style: _style(fonts.regular, 8),
    ),
    pw.SizedBox(height: 9),
    _PixelStrip(),
  ];

  /// Label on the left, value right-aligned; a long value wraps instead of
  /// pushing the label off the paper.
  static pw.Widget _row(
    pw.Widget label,
    pw.Widget value, {
    int valueFlex = 2,
    bool alignTop = false,
  }) => pw.Row(
    crossAxisAlignment: alignTop
        ? pw.CrossAxisAlignment.start
        : pw.CrossAxisAlignment.end,
    children: [
      label,
      pw.SizedBox(width: 8),
      pw.Expanded(
        flex: valueFlex,
        child: pw.Align(alignment: pw.Alignment.centerRight, child: value),
      ),
    ],
  );
}

/// A thin, evenly dashed separator drawn as filled rectangles (thermal
/// drivers on the GDI path render fills more reliably than dashed strokes).
class _DashedRule extends pw.StatelessWidget {
  _DashedRule();

  static const double _dash = 3;
  static const double _gap = 2.2;
  static const double _thickness = 0.8;

  @override
  pw.Widget build(pw.Context context) => pw.CustomPaint(
    size: const PdfPoint(double.infinity, _thickness),
    painter: (canvas, size) {
      final count = ((size.x + _gap) / (_dash + _gap)).floor();
      // Spread the remainder so both ends finish on a full dash.
      final step = count > 1 ? (size.x - _dash) / (count - 1) : 0.0;
      canvas.setFillColor(PdfColors.black);
      for (var i = 0; i < count; i++) {
        canvas.drawRect(i * step, 0, _dash, size.y);
      }
      canvas.fillPath();
    },
  );
}

/// The brand mark: a two-row checkerboard of "pixels" across the paper.
class _PixelStrip extends pw.StatelessWidget {
  _PixelStrip();

  static const double _cell = 3.4;

  @override
  pw.Widget build(pw.Context context) => pw.CustomPaint(
    size: const PdfPoint(double.infinity, _cell * 2),
    painter: (canvas, size) {
      final columns = (size.x / _cell).floor();
      final offset = (size.x - columns * _cell) / 2;
      canvas.setFillColor(PdfColors.black);
      for (var column = 0; column < columns; column++) {
        // Bottom row on even columns, top row on odd ones (y grows upward).
        final y = column.isEven ? 0.0 : _cell;
        canvas.drawRect(offset + column * _cell, y, _cell, _cell);
      }
      canvas.fillPath();
    },
  );
}
