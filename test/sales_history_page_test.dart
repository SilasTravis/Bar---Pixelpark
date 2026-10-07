import 'package:bar_app/core/theme/app_theme.dart';
import 'package:bar_app/features/sale/domain/bar_sale.dart';
import 'package:bar_app/features/sales_history/presentation/cubit/sales_history_cubit.dart';
import 'package:bar_app/features/sales_history/presentation/pages/sales_history_page.dart';
import 'package:bar_app/features/shift/presentation/cubit/shift_cubit.dart';
import 'package:bar_app/generated/l10n.dart';
import 'package:bar_app/injector_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';
import 'helpers/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSalesRepository sales;

  setUp(() {
    // The frameless title bar asks window_manager about the window.
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('window_manager'),
          (call) async => false,
        );
    sales = FakeSalesRepository();
    sl.registerFactory<SalesHistoryCubit>(() => SalesHistoryCubit(sales));
  });

  tearDown(() => sl.unregister<SalesHistoryCubit>());

  testWidgets('mixed sale: purple Aralash chip + N/K split', (tester) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    sales.shiftSales = [
      saleFixture(
        receiptNo: 2,
        method: PaymentMethod.mixed,
        totalUzs: 44000,
        cashUzs: 30000,
      ),
      saleFixture(receiptNo: 1, method: PaymentMethod.card),
    ];
    final shiftCubit = ShiftCubit(FakeShiftRepository());
    addTearDown(shiftCubit.close);

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
          home: const SalesHistoryPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aralash'), findsOneWidget);
    expect(find.text('N 30 000 · K 14 000'), findsOneWidget);
    expect(find.text('Karta'), findsOneWidget);
    expect(find.textContaining(' · K '), findsOneWidget, reason: 'only mixed');
  });
}
