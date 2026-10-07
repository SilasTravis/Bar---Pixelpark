import 'package:bar_app/core/theme/app_theme.dart';
import 'package:bar_app/features/sale/presentation/widgets/mixed_payment_dialog.dart';
import 'package:bar_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Finder fieldIn(String key) => find.descendant(
    of: find.byKey(ValueKey(key)),
    matching: find.byType(TextField),
  );
  final cashField = fieldIn('mixed-cash');
  final cardField = fieldIn('mixed-card');
  final payButton = find.byKey(const ValueKey('mixed-pay'));

  String textOf(WidgetTester tester, Finder field) =>
      tester.widget<TextField>(field).controller!.text;

  bool payEnabled(WidgetTester tester) =>
      tester.widget<ButtonStyleButton>(payButton).onPressed != null;

  /// Opens the dialog from a button; [results] collects what it resolves to.
  Future<void> open(
    WidgetTester tester, {
    required int total,
    required List<int?> results,
    Locale locale = const Locale('uz'),
  }) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        locale: locale,
        supportedLocales: AppLocalization.delegate.supportedLocales,
        localizationsDelegates: const [
          AppLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => results.add(
                await showMixedPaymentDialog(context, totalUzs: total),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the total; Naqd is focused; pay starts disabled', (
    tester,
  ) async {
    await open(tester, total: 44000, results: []);
    expect(find.text("Jami: 44 000 so'm"), findsOneWidget);
    expect(tester.widget<TextField>(cashField).focusNode!.hasFocus, isTrue);
    expect(payEnabled(tester), isFalse);
    expect(
      find.text('Naqd va karta jami summaga teng bo‘lishi kerak'),
      findsNothing,
    );
  });

  testWidgets('typing in Naqd fills Karta, and confirm returns the cash', (
    tester,
  ) async {
    final results = <int?>[];
    await open(tester, total: 44000, results: results);

    await tester.enterText(cashField, '30000');
    await tester.pump();
    expect(textOf(tester, cashField), '30 000', reason: 'grouped as typed');
    expect(textOf(tester, cardField), '14 000');
    expect(payEnabled(tester), isTrue);

    await tester.tap(payButton);
    await tester.pumpAndSettle();
    expect(results, [30000]);
    expect(find.byType(MixedPaymentDialog), findsNothing);
  });

  testWidgets('typing in Karta fills Naqd; the last edited field drives', (
    tester,
  ) async {
    await open(tester, total: 44000, results: []);
    await tester.enterText(cashField, '30000');
    await tester.enterText(cardField, '4000');
    await tester.pump();
    expect(textOf(tester, cashField), '40 000');
    expect(textOf(tester, cardField), '4 000');
    expect(payEnabled(tester), isTrue);
  });

  testWidgets('more than the total: Karta 0, pay disabled, hint shown', (
    tester,
  ) async {
    final results = <int?>[];
    await open(tester, total: 44000, results: results);
    await tester.enterText(cashField, '50000');
    await tester.pump();
    expect(textOf(tester, cardField), '0');
    expect(payEnabled(tester), isFalse);
    expect(
      find.text('Naqd va karta jami summaga teng bo‘lishi kerak'),
      findsOneWidget,
    );

    // Enter does not pay an invalid split.
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.byType(MixedPaymentDialog), findsOneWidget);
    expect(results, isEmpty);
  });

  testWidgets('the whole total in one field is not a split', (tester) async {
    await open(tester, total: 44000, results: []);
    await tester.enterText(cardField, '44000');
    await tester.pump();
    expect(textOf(tester, cashField), '0');
    expect(payEnabled(tester), isFalse);
  });

  testWidgets('clearing a field clears the other', (tester) async {
    await open(tester, total: 44000, results: []);
    await tester.enterText(cashField, '30000');
    await tester.enterText(cashField, '');
    await tester.pump();
    expect(textOf(tester, cardField), '');
    expect(payEnabled(tester), isFalse);
  });

  testWidgets('Enter pays a valid split', (tester) async {
    final results = <int?>[];
    await open(tester, total: 44000, results: results);
    await tester.enterText(cashField, '20000');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(results, [20000]);
  });

  testWidgets('Esc cancels', (tester) async {
    final results = <int?>[];
    await open(tester, total: 44000, results: results);
    await tester.enterText(cashField, '20000');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(MixedPaymentDialog), findsNothing);
    expect(results, [null]);
  });

  testWidgets('quick-fill chips: only notes below the total', (tester) async {
    await open(tester, total: 44000, results: []);
    expect(find.widgetWithText(ActionChip, '10 000'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, '20 000'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, '50 000'), findsNothing);

    await tester.tap(find.widgetWithText(ActionChip, '20 000'));
    await tester.pump();
    expect(textOf(tester, cashField), '20 000');
    expect(textOf(tester, cardField), '24 000');
    expect(payEnabled(tester), isTrue);
  });

  testWidgets('Russian labels', (tester) async {
    await open(tester, total: 44000, results: [], locale: const Locale('ru'));
    expect(find.text('Смешанная оплата'), findsOneWidget);
    expect(find.text("Итого: 44 000 so'm"), findsOneWidget);
    expect(find.text('Оплатить'), findsOneWidget);
  });
}
