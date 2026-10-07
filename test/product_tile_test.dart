import 'package:bar_app/core/theme/app_theme.dart';
import 'package:bar_app/features/products/domain/bar_product.dart';
import 'package:bar_app/features/products/presentation/product_icon.dart';
import 'package:bar_app/features/sale/presentation/widgets/product_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fixtures.dart';

void main() {
  /// [coffee] (icon `ph-coffee`) with a photo URL. Under flutter_test every
  /// HTTP request answers 400, so this image always fails to load.
  const coffeeWithPhoto = BarProduct(
    id: 'p-coffee',
    name: 'Kofe',
    category: 'Issiq',
    icon: 'ph-coffee',
    priceUzs: 18000,
    imageUrl: 'https://cdn.pixelpark.uz/bar/kofe.jpg',
  );

  final fallbackIcon = find.byIcon(productIconFor('ph-coffee'));

  Future<void> pumpTile(
    WidgetTester tester,
    BarProduct product, {
    int qtyInCart = 0,
    VoidCallback? onTap,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              height: 230,
              child: ProductTile(
                product: product,
                qtyInCart: qtyInCart,
                onTap: onTap ?? () {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('no imageUrl → icon fallback, no network image', (tester) async {
    await pumpTile(tester, coffee);
    await tester.pumpAndSettle();

    expect(fallbackIcon, findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(find.text('Kofe'), findsOneWidget);
    expect(find.text("18 000 so'm"), findsOneWidget);
  });

  testWidgets('image loading → icon fallback until the first frame', (
    tester,
  ) async {
    await pumpTile(tester, coffeeWithPhoto);

    expect(find.byType(Image), findsOneWidget);
    expect(fallbackIcon, findsOneWidget);
  });

  testWidgets('image fails → icon fallback, no error surfaced', (tester) async {
    await pumpTile(tester, coffeeWithPhoto);
    // Let the (mocked, failing) HTTP request complete for real.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();

    expect(fallbackIcon, findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.text('Kofe'), findsOneWidget);
  });

  testWidgets('photo never blocks the tap; cart quantity badge shows', (
    tester,
  ) async {
    var taps = 0;
    await pumpTile(tester, coffeeWithPhoto, qtyInCart: 3, onTap: () => taps++);

    // Still loading: tap on the photo area itself.
    await tester.tap(fallbackIcon);
    await tester.tap(find.text('Kofe'));
    expect(taps, 2);
    expect(find.text('3'), findsOneWidget);
  });
}
