import 'package:bar_app/core/error/failure.dart';
import 'package:bar_app/core/theme/app_theme.dart';
import 'package:bar_app/features/incomes/domain/bar_income.dart';
import 'package:bar_app/features/incomes/presentation/cubit/incomes_cubit.dart';
import 'package:bar_app/features/incomes/presentation/pages/incomes_page.dart';
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

  late FakeIncomesRepository incomes;
  late FakeShiftRepository shifts;
  late ShiftCubit shiftCubit;

  setUp(() {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('window_manager'),
          (call) async => false,
        );
    incomes = FakeIncomesRepository();
    var n = 0;
    sl.registerFactory<IncomesCubit>(
      () => IncomesCubit(incomes, newClientIncomeId: () => 'key-${++n}'),
    );
    shifts = FakeShiftRepository();
    // Refreshes after every add / delete.
    for (var i = 0; i < 5; i++) {
      shifts.currentResults.add(Right(_shift()));
    }
    shiftCubit = ShiftCubit(shifts);
  });

  tearDown(() async {
    sl.unregister<IncomesCubit>();
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
          home: const IncomesPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty → quick pick → Enter saves → row + totals', (
    tester,
  ) async {
    incomes.suggestions = const [
      IncomeSuggestion(name: 'Sut', lastAmountUzs: 25000, count: 7),
    ];
    await pumpPage(tester);
    expect(find.text('Bu smenada hali kirim yo‘q'), findsOneWidget);
    expect(find.text("0 so'm"), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Yangi kirim'));
    await tester.pumpAndSettle();

    // Validation: nothing typed.
    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();
    expect(find.text('Nomini kiriting'), findsOneWidget);
    expect(incomes.created, isEmpty);

    await tester.tap(find.text('Sut · 25 000'));
    await tester.pumpAndSettle();
    expect(find.text('25 000'), findsOneWidget, reason: 'amount prefilled');

    incomes.createResults.add(Right(incomeFixture(note: '2 litr')));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final request = incomes.created.single;
    expect(request.clientIncomeId, 'key-1');
    expect(request.name, 'Sut');
    expect(request.amountUzs, 25000);
    expect(request.receivedTo, IncomeReceivedTo.cash);

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Sut'), findsOneWidget);
    expect(find.text('2 litr'), findsOneWidget);
    expect(find.text('Kassaga: 25 000 so\'m'), findsOneWidget);
  });

  testWidgets('"Boshqa" is sent as other; failure keeps the dialog + key', (
    tester,
  ) async {
    await pumpPage(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Yangi kirim'));
    await tester.pumpAndSettle();
    final fields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), 'Muz');
    await tester.enterText(fields.at(1), '12000');
    await tester.tap(find.text('Boshqa'));
    await tester.pumpAndSettle();

    incomes.createResults
      ..add(Left(NoInternetFailure()))
      ..add(
        Right(
          incomeFixture(
            id: 'e-2',
            name: 'Muz',
            amountUzs: 12000,
            receivedTo: IncomeReceivedTo.other,
          ),
        ),
      );
    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Internet'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();
    expect(incomes.created.map((r) => r.clientIncomeId), ['key-1', 'key-1']);
    expect(incomes.created.last.receivedTo, IncomeReceivedTo.other);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text("12 000 so'm"), findsWidgets);
    expect(find.text("Kassaga: 0 so'm"), findsOneWidget);
  });

  testWidgets('delete asks first, then removes the row', (tester) async {
    incomes.shiftIncomes = [incomeFixture()];
    await pumpPage(tester);
    expect(find.text('Sut'), findsOneWidget);

    await tester.tap(find.byTooltip('O‘chirish'));
    await tester.pumpAndSettle();
    expect(find.text('Kirimni o‘chirish'), findsOneWidget);
    await tester.tap(find.text('Ha, o‘chirish'));
    await tester.pumpAndSettle();

    expect(incomes.deleted, ['inc-1']);
    expect(find.text('Sut'), findsNothing);
    expect(find.text('Bu smenada hali kirim yo‘q'), findsOneWidget);
  });
}
