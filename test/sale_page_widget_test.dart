import 'package:bar_app/core/printing/bar_receipt_printer.dart';
import 'package:bar_app/core/theme/app_theme.dart';
import 'package:bar_app/features/auth/domain/entities/bar_cashier.dart';
import 'package:bar_app/features/auth/presentation/cubit/session_cubit.dart';
import 'package:bar_app/features/sale/domain/bar_sale.dart';
import 'package:bar_app/features/sale/presentation/cubit/sale_cubit.dart';
import 'package:bar_app/features/sale/presentation/pages/sale_page.dart';
import 'package:bar_app/features/shift/presentation/cubit/shift_cubit.dart';
import 'package:bar_app/features/shift/presentation/pages/open_shift_view.dart';
import 'package:bar_app/core/error/failure.dart';
import 'package:bar_app/generated/l10n.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';
import 'helpers/fixtures.dart';

void main() {
  late FakeSalesRepository sales;
  late FakeShiftRepository shifts;
  late SaleCubit saleCubit;
  late ShiftCubit shiftCubit;
  late SessionCubit sessionCubit;

  setUp(() {
    sales = FakeSalesRepository();
    shifts = FakeShiftRepository();
    saleCubit = SaleCubit(
      FakeProductsRepository([cola, coffee, chips]),
      sales,
      newClientSaleId: () => 'uuid-1',
    );
    shiftCubit = ShiftCubit(shifts);
    sessionCubit = SessionCubit(
      FakeAuthRepository(
        const BarCashier(
          id: 'c-1',
          fullName: 'Aziz',
          username: 'aziz',
          bar: bar,
        ),
      ),
    );
  });

  tearDown(() async {
    await saleCubit.close();
    await shiftCubit.close();
    await sessionCubit.close();
  });

  /// The sale area at the app's minimum window (800x600) minus the title
  /// bar and header.
  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(800, 490);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: saleCubit),
          BlocProvider.value(value: shiftCubit),
          BlocProvider.value(value: sessionCubit),
        ],
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
          home: Scaffold(body: child),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'tap products → cart → network failure keeps cart → retry sells',
    (tester) async {
      await saleCubit.loadProducts();
      await pump(
        tester,
        SalePage(receiptPrinter: BarReceiptPrinter(printerName: () => null)),
      );

      expect(find.text('Hammasi'), findsOneWidget);
      expect(find.text('Ichimliklar'), findsOneWidget);
      expect(find.text('Kofe'), findsOneWidget);

      await tester.tap(find.text('Coca-Cola 0.5'));
      await tester.tap(find.text('Coca-Cola 0.5'));
      await tester.tap(find.text('Kofe'));
      await tester.pumpAndSettle();
      expect(find.text("42 000 so'm"), findsOneWidget, reason: 'cart total');

      sales.createResults
        ..add(Left(NoInternetFailure()))
        ..add(Right(saleFixture(receiptNo: 12, totalUzs: 42000)));
      // The shift refresh after a successful sale.
      shifts.currentResults.add(const Right(null));

      await tester.tap(find.text('Naqd'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Internet aloqasi yo‘q'), findsOneWidget);
      expect(find.text("42 000 so'm"), findsOneWidget, reason: 'cart kept');

      await tester.tap(find.text('Naqd'));
      await tester.pumpAndSettle();
      expect(sales.requests.map((r) => r.clientSaleId), ['uuid-1', 'uuid-1']);
      expect(find.textContaining('Chek #12'), findsOneWidget);
      expect(find.textContaining('Savat bo‘sh'), findsOneWidget);
    },
  );

  testWidgets('category tab filters the grid', (tester) async {
    await saleCubit.loadProducts();
    await pump(
      tester,
      SalePage(receiptPrinter: BarReceiptPrinter(printerName: () => null)),
    );
    await tester.tap(find.text('Issiq'));
    await tester.pumpAndSettle();
    expect(find.text('Kofe'), findsOneWidget);
    expect(find.text('Coca-Cola 0.5'), findsNothing);
  });

  testWidgets('open-shift screen fits and opens a shift', (tester) async {
    shifts.currentResults.add(const Right(null));
    await shiftCubit.load();
    await pump(tester, const OpenShiftView());
    expect(find.text('Smenani ochish'), findsOneWidget);
    expect(shiftCubit.state.status, ShiftStatus.none);
  });

  test('payment method enum maps to the API values', () {
    expect(PaymentMethod.cash.apiValue, 'cash');
    expect(PaymentMethod.card.apiValue, 'card');
  });
}
