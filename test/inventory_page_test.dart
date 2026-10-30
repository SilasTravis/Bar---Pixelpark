import 'package:bar_app/core/error/failure.dart';
import 'package:bar_app/core/theme/app_theme.dart';
import 'package:bar_app/features/inventory/domain/stock_item.dart';
import 'package:bar_app/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:bar_app/features/inventory/presentation/pages/inventory_page.dart';
import 'package:bar_app/features/products/domain/products_repository.dart';
import 'package:bar_app/generated/l10n.dart';
import 'package:bar_app/injector_container.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';
import 'helpers/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeInventoryRepository inventory;

  setUp(() {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('window_manager'),
          (call) async => false,
        );
    inventory = FakeInventoryRepository();
    var n = 0;
    sl.registerFactory<InventoryCubit>(
      () => InventoryCubit(inventory, newRequestId: () => 'key-${++n}'),
    );
    sl.registerSingleton<ProductsRepository>(
      FakeProductsRepository([coffee, cola]),
    );
  });

  tearDown(() {
    sl.unregister<InventoryCubit>();
    sl.unregister<ProductsRepository>();
  });

  Finder dialogField() => find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(TextField),
  );

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        locale: const Locale('uz'),
        supportedLocales: AppLocalization.delegate.supportedLocales,
        localizationsDelegates: const [
          AppLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const InventoryPage(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty state, then create an item through the dialog', (
    tester,
  ) async {
    await pumpPage(tester);
    expect(find.text('Omborda hali mahsulot yo‘q'), findsOneWidget);

    await tester.tap(find.text('Yangi mahsulot'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();
    expect(find.text('Nomini kiriting'), findsOneWidget);
    expect(inventory.createdItems, isEmpty);

    await tester.enterText(dialogField().first, 'Kofe');
    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();

    expect(inventory.createdItems.single.name, 'Kofe');
    expect(inventory.createdItems.single.unit, StockUnit.g);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('0 g'), findsOneWidget);
    expect(find.text('Tugadi'), findsOneWidget);
  });

  testWidgets('rows show qty and ok / kam / tugadi badges; low filter', (
    tester,
  ) async {
    inventory.items = [
      stockFixture(qtyOnHand: 2500),
      stockFixture(id: 'm', name: 'Sut', unit: StockUnit.ml, qtyOnHand: 800),
      stockFixture(id: 's', name: 'Shakar', qtyOnHand: 0),
    ];
    await pumpPage(tester);
    expect(find.text('2,5 kg'), findsOneWidget);
    expect(find.text('Yetarli'), findsOneWidget);
    expect(find.text('Kam'), findsOneWidget);
    expect(find.text('Tugadi'), findsOneWidget);

    await tester.tap(find.text('Kam qolganlar'));
    await tester.pumpAndSettle();
    expect(find.text('Kofe'), findsNothing);
    expect(find.text('Sut'), findsOneWidget);
    expect(find.text('Shakar'), findsOneWidget);
  });

  testWidgets('kirim from the item sheet, typing kg', (tester) async {
    inventory.items = [stockFixture(qtyOnHand: 500)];
    await pumpPage(tester);
    await tester.tap(find.text('Kofe'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Kirim'));
    await tester.pumpAndSettle();

    await tester.enterText(dialogField().first, '1,5');
    await tester.tap(find.text('kg'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();

    final request = inventory.batches.single;
    expect(request.qty, 1500);
    expect(request.requestId, 'key-1');
    expect(request.reason, isNull);
    // The sheet shows the new balance (2 kg).
    expect(find.textContaining('Qoldiq: 2 kg'), findsOneWidget);
  });

  testWidgets('brak needs a reason; failure keeps the dialog and the key', (
    tester,
  ) async {
    inventory.items = [stockFixture()];
    await pumpPage(tester);
    await tester.tap(find.text('Kofe'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Brak'));
    await tester.pumpAndSettle();

    await tester.enterText(dialogField().first, '200');
    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();
    expect(find.text('Sababni kiriting (kamida 2 belgi)'), findsOneWidget);
    expect(inventory.batches, isEmpty);

    await tester.enterText(dialogField().last, 'Buzilgan');
    inventory.batchResults.add(Left(NoInternetFailure()));
    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();
    expect(inventory.batches.map((b) => b.requestId), ['key-1', 'key-1']);
    expect(inventory.batches.last.reason, 'Buzilgan');
    expect(inventory.items.single.qtyOnHand, 4800);
  });

  testWidgets('inventory endpoint missing: plain message, retry offered', (
    tester,
  ) async {
    inventory.itemsFailure = ServerFailure(message: 'nf', statusCode: 404);
    await pumpPage(tester);
    expect(find.textContaining('Savdo odatdagidek'), findsOneWidget);
    expect(find.text('Qayta urinish'), findsOneWidget);
  });

  testWidgets('recipe editor: kofe = 10 g coffee + 150 ml milk', (
    tester,
  ) async {
    inventory.items = [
      stockFixture(),
      stockFixture(id: 'm', name: 'Sut', unit: StockUnit.ml),
    ];
    await pumpPage(tester);
    await tester.tap(find.text('Retseptlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kofe'));
    await tester.pumpAndSettle();

    Future<void> addLine(int index, String ingredient, String qty) async {
      await tester.tap(find.text('Ingredient qo‘shish'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>).at(index));
      await tester.pumpAndSettle();
      await tester.tap(find.text(ingredient).last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find
            .descendant(
              of: find.byType(AlertDialog),
              matching: find.byType(TextField),
            )
            .at(index),
        qty,
      );
      await tester.pumpAndSettle();
    }

    await addLine(0, 'Kofe', '10');
    await addLine(1, 'Sut', '150');
    await tester.tap(find.widgetWithText(FilledButton, 'Saqlash'));
    await tester.pumpAndSettle();

    final saved = inventory.savedSetups.single;
    expect(saved.productId, 'p-coffee');
    expect(saved.kind, ProductKind.prepared);
    expect(saved.recipe.map((l) => (l.stockItemId, l.qty)), [
      ('s-coffee', 10),
      ('m', 150),
    ]);
  });
}
