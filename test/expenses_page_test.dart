import 'package:bar_app/core/error/failure.dart';
import 'package:bar_app/core/theme/app_theme.dart';
import 'package:bar_app/features/expenses/domain/bar_expense.dart';
import 'package:bar_app/features/expenses/presentation/cubit/expenses_cubit.dart';
import 'package:bar_app/features/expenses/presentation/pages/expenses_page.dart';
import 'package:bar_app/features/shift/domain/bar_shift.dart';
import 'package:bar_app/features/shift/presentation/cubit/shift_cubit.dart';
import 'package:bar_app/generated/l10n.dart';
import 'package:bar_app/injector_container.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';
import 'helpers/fixtures.dart';

BarShift _shift() => BarShift(
  id: 'shift-1',
  bar: bar,
  cashierId: 'c-1',
  cashierName: 'Aziz',
  openedAt: DateTime.utc(2026, 10, 15, 4),
  cashTotalUzs: 100000,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeExpensesRepository expenses;
  late FakeShiftRepository shifts;
  late ShiftCubit shiftCubit;

  setUp(() {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('window_manager'),
          (call) async => false,
        );
    expenses = FakeExpensesRepository();
    var n = 0;
    sl.registerFactory<ExpensesCubit>(
      () => ExpensesCubit(expenses, newClientExpenseId: () => 'key-${++n}'),
    );
    shifts = FakeShiftRepository();
    // Refreshes after every add / delete.
    for (var i = 0; i < 5; i++) {
      shifts.currentResults.add(Right(_shift()));
    }
    shiftCubit = ShiftCubit(shifts);
  });

  tearDown(() async {
    sl.unregister<ExpensesCubit>();
    await shiftCubit.close();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BlocProvider.value(
        value: shiftCubit,
        child: MaterialApp(
          theme: appTheme,
          locale: const Locale('uz'),
          supportedLocales: AppLocalization.delegate.supportedLocales,
          localizationsDelegates: const [
            AppLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const ExpensesPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty → quick pick → Enter saves → row + totals', (
    tester,
  ) async {
    expenses.suggestions = const [
      ExpenseSuggestion(name: 'Sut', lastAmountUzs: 25000, count: 7),
    ];
    await pumpPage(tester);
    expect(find.text('Bu smenada hali chiqim yo‘q'), findsOneWidget);
    expect(find.text("0 so'm"), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Yangi chiqim'));
    await tester.pumpAndSettle();

    // Validation: nothing typed.
    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();
    expect(find.text('Nomini kiriting'), findsOneWidget);
    expect(expenses.created, isEmpty);

    await tester.tap(find.text('Sut · 25 000'));
    await tester.pumpAndSettle();
    expect(find.text('25 000'), findsOneWidget, reason: 'amount prefilled');

    expenses.createResults.add(Right(expenseFixture(note: '2 litr')));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final request = expenses.created.single;
    expect(request.clientExpenseId, 'key-1');
    expect(request.name, 'Sut');
    expect(request.amountUzs, 25000);
    expect(request.paidFrom, ExpensePaidFrom.cash);

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Sut'), findsOneWidget);
    expect(find.text('2 litr'), findsOneWidget);
    expect(find.text('Kassadan: 25 000 so\'m'), findsOneWidget);
  });

  testWidgets('"Boshqa" is sent as other; failure keeps the dialog + key', (
    tester,
  ) async {
    await pumpPage(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Yangi chiqim'));
    await tester.pumpAndSettle();
    final fields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), 'Muz');
    await tester.enterText(fields.at(1), '12000');
    await tester.tap(find.text('Boshqa'));
    await tester.pumpAndSettle();

    expenses.createResults
      ..add(Left(NoInternetFailure()))
      ..add(
        Right(
          expenseFixture(
            id: 'e-2',
            name: 'Muz',
            amountUzs: 12000,
            paidFrom: ExpensePaidFrom.other,
          ),
        ),
      );
    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Internet'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();
    expect(expenses.created.map((r) => r.clientExpenseId), ['key-1', 'key-1']);
    expect(expenses.created.last.paidFrom, ExpensePaidFrom.other);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text("12 000 so'm"), findsWidgets);
    expect(find.text("Kassadan: 0 so'm"), findsOneWidget);
  });

  testWidgets('delete asks first, then removes the row', (tester) async {
    expenses.shiftExpenses = [expenseFixture()];
    await pumpPage(tester);
    expect(find.text('Sut'), findsOneWidget);

    await tester.tap(find.byTooltip('O‘chirish'));
    await tester.pumpAndSettle();
    expect(find.text('Chiqimni o‘chirish'), findsOneWidget);
    await tester.tap(find.text('Ha, o‘chirish'));
    await tester.pumpAndSettle();

    expect(expenses.deleted, ['exp-1']);
    expect(find.text('Sut'), findsNothing);
    expect(find.text('Bu smenada hali chiqim yo‘q'), findsOneWidget);
  });
}
