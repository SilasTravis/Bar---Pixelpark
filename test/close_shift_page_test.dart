import 'package:bar_app/core/theme/app_theme.dart';
import 'package:bar_app/features/shift/domain/bar_shift.dart';
import 'package:bar_app/features/shift/presentation/cubit/shift_cubit.dart';
import 'package:bar_app/features/shift/presentation/pages/close_shift_page.dart';
import 'package:bar_app/generated/l10n.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';
import 'helpers/fixtures.dart';

BarShift _shift({DateTime? closedAt, int? counted, int? difference}) =>
    BarShift(
      id: 'shift-1',
      bar: bar,
      cashierId: 'c-1',
      cashierName: 'Aziz',
      openedAt: DateTime.utc(2026, 10, 6, 4),
      closedAt: closedAt,
      cashTotalUzs: 50000,
      cardTotalUzs: 30000,
      totalUzs: 80000,
      salesCount: 5,
      refundedCount: 1,
      countedCashUzs: counted,
      cashDifferenceUzs: difference,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // The frameless title bar asks window_manager about the window.
    TestDefaultBinaryMessenger messenger =
        TestWidgetsFlutterBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('window_manager'),
      (call) async => false,
    );
  });

  testWidgets('counted cash → live difference → confirm → summary → back', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repo = FakeShiftRepository();
    repo.currentResults
      ..add(Right(_shift()))
      ..add(Right(_shift())); // the page's own refresh
    final cubit = ShiftCubit(repo);
    addTearDown(cubit.close);
    await cubit.load();

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
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
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: const CloseShiftPage(),
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text("50 000 so'm"), findsWidgets); // naqd + kutilgan
    expect(find.text("80 000 so'm"), findsOneWidget); // jami
    expect(find.text('—'), findsOneWidget, reason: 'no difference yet');

    await tester.enterText(find.byType(TextField).first, '48000');
    await tester.pumpAndSettle();
    expect(find.text('48 000'), findsOneWidget, reason: 'grouped as typed');
    expect(find.text("-2 000 so'm"), findsOneWidget);

    repo.closeResults.add(
      Right(
        _shift(
          closedAt: DateTime.utc(2026, 10, 6, 16),
          counted: 48000,
          difference: -2000,
        ),
      ),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Smenani yopish'));
    await tester.pumpAndSettle();
    expect(find.text('Smenani yopasizmi?'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Smenani yopish'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.closedWith, [48000]);
    expect(find.text('Smena yopildi'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(CloseShiftPage), findsNothing);
    expect(cubit.state.status, ShiftStatus.none);
  });
}
