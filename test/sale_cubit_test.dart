import 'dart:async';

import 'package:bar_app/core/error/failure.dart';
import 'package:bar_app/features/sale/domain/bar_sale.dart';
import 'package:bar_app/features/sale/domain/cart.dart';
import 'package:bar_app/features/sale/presentation/cubit/sale_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';
import 'helpers/fixtures.dart';

void main() {
  late FakeProductsRepository products;
  late FakeSalesRepository sales;
  late SaleCubit cubit;
  var minted = 0;

  setUp(() async {
    minted = 0;
    products = FakeProductsRepository([cola, coffee, chips]);
    sales = FakeSalesRepository();
    cubit = SaleCubit(
      products,
      sales,
      newClientSaleId: () => 'uuid-${++minted}',
    );
    await cubit.loadProducts();
  });

  tearDown(() => cubit.close());

  test('loads products and derives category tabs in catalog order', () {
    expect(cubit.state.productsStatus, ProductsStatus.loaded);
    expect(cubit.state.categories, ['Ichimliklar', 'Issiq', 'Gazaklar']);
    cubit.selectCategory('Issiq');
    expect(cubit.state.visibleProducts, [coffee]);
    cubit.selectCategory(null);
    expect(cubit.state.visibleProducts, hasLength(3));
  });

  test(
    'a network failure keeps the cart and retry re-sends the SAME id',
    () async {
      cubit
        ..addProduct(cola)
        ..addProduct(cola)
        ..addProduct(coffee);
      sales.createResults
        ..add(Left(NoInternetFailure()))
        ..add(Left(ServerFailure(message: 'boom', statusCode: 502)))
        ..add(Right(saleFixture(receiptNo: 7)));

      await cubit.checkout(PaymentMethod.cash);
      expect(cubit.state.cart.lines, hasLength(2));
      expect(cubit.state.cart.clientSaleId, 'uuid-1');
      expect(cubit.state.outcome, isA<SaleFailed>());
      expect(cubit.state.isSubmitting, isFalse);

      await cubit.checkout(PaymentMethod.cash); // 5xx
      expect(cubit.state.cart.clientSaleId, 'uuid-1');

      await cubit.checkout(PaymentMethod.cash); // success
      expect(sales.requests.map((r) => r.clientSaleId), [
        'uuid-1',
        'uuid-1',
        'uuid-1',
      ]);
      expect(sales.requests.first.items, [
        {'productId': 'p-cola', 'quantity': 2},
        {'productId': 'p-coffee', 'quantity': 1},
      ]);
      expect(minted, 1);
    },
  );

  test('success clears the cart and the next sale gets a new id', () async {
    sales.createResults
      ..add(Right(saleFixture(receiptNo: 1)))
      ..add(Right(saleFixture(receiptNo: 2)));

    cubit.addProduct(cola);
    await cubit.checkout(PaymentMethod.card);
    expect(cubit.state.cart, Cart.empty);
    final outcome = cubit.state.outcome;
    expect(outcome, isA<SaleSucceeded>());
    expect((outcome as SaleSucceeded).sale.receiptNo, 1);

    cubit.addProduct(cola);
    await cubit.checkout(PaymentMethod.card);
    expect(sales.requests.map((r) => r.clientSaleId), ['uuid-1', 'uuid-2']);
    expect(sales.requests.map((r) => r.method), [
      PaymentMethod.card,
      PaymentMethod.card,
    ]);
  });

  test('changing the cart after a failure resets the id', () async {
    sales.createResults
      ..add(Left(NoInternetFailure()))
      ..add(Right(saleFixture()));
    cubit.addProduct(cola);
    await cubit.checkout(PaymentMethod.cash);
    expect(cubit.state.cart.clientSaleId, 'uuid-1');

    cubit.addProduct(chips);
    expect(cubit.state.cart.clientSaleId, isNull);
    expect(cubit.state.outcome, isNull, reason: 'stale error is dropped');

    await cubit.checkout(PaymentMethod.cash);
    expect(sales.requests.map((r) => r.clientSaleId), ['uuid-1', 'uuid-2']);
  });

  test('switching the payment method on retry keeps the id', () async {
    sales.createResults
      ..add(Left(NoInternetFailure()))
      ..add(Right(saleFixture()));
    cubit.addProduct(cola);
    await cubit.checkout(PaymentMethod.cash);
    await cubit.checkout(PaymentMethod.card);
    expect(sales.requests.map((r) => r.clientSaleId), ['uuid-1', 'uuid-1']);
  });

  test('checkoutMixed sends the cash part; server returns the split', () async {
    sales.createResults.add(
      Right(
        saleFixture(
          receiptNo: 3,
          method: PaymentMethod.mixed,
          totalUzs: 42000,
          cashUzs: 30000,
        ),
      ),
    );
    cubit
      ..addProduct(cola)
      ..addProduct(cola)
      ..addProduct(coffee); // 42 000

    await cubit.checkoutMixed(cashUzs: 30000);
    expect(
      sales.requests.single.payment,
      const SalePayment.mixed(cashUzs: 30000),
    );
    expect(cubit.state.cart, Cart.empty);
    final sale = (cubit.state.outcome as SaleSucceeded).sale;
    expect((sale.cashUzs, sale.cardUzs), (30000, 12000));
  });

  test('checkoutMixed ignores a split that is not 0 < cash < total', () async {
    cubit.addProduct(cola); // 12 000
    await cubit.checkoutMixed(cashUzs: 0);
    await cubit.checkoutMixed(cashUzs: -5);
    await cubit.checkoutMixed(cashUzs: 12000);
    await cubit.checkoutMixed(cashUzs: 50000);
    await cubit.checkout(PaymentMethod.mixed); // no cash part → nothing
    expect(sales.requests, isEmpty);
    expect(cubit.state.cart.clientSaleId, isNull);
  });

  test('checkoutMixed on an empty cart never submits', () async {
    await cubit.checkoutMixed(cashUzs: 1);
    expect(sales.requests, isEmpty);
  });

  test('while a split is in flight the mixed method is submitting', () async {
    sales.gate = Completer<void>();
    sales.createResults.add(Right(saleFixture()));
    cubit.addProduct(cola);
    final pending = cubit.checkoutMixed(cashUzs: 2000);
    expect(cubit.state.submittingMethod, PaymentMethod.mixed);
    unawaited(cubit.checkout(PaymentMethod.cash)); // ignored
    sales.gate!.complete();
    await pending;
    expect(sales.requests, hasLength(1));
  });

  test(
    'switching between cash and a split on retry keeps the SAME id',
    () async {
      sales.createResults
        ..add(Left(NoInternetFailure()))
        ..add(
          Left(
            ServerFailure(
              message: 'split',
              code: BarErrorCodes.invalidPaymentSplit,
              statusCode: 400,
            ),
          ),
        )
        ..add(Right(saleFixture()));
      cubit.addProduct(cola);

      await cubit.checkout(PaymentMethod.cash);
      await cubit.checkoutMixed(cashUzs: 5000);
      expect(cubit.state.cart.clientSaleId, 'uuid-1');
      expect(cubit.state.outcome, isA<SaleFailed>());
      await cubit.checkoutMixed(cashUzs: 7000);

      expect(sales.requests.map((r) => r.clientSaleId), [
        'uuid-1',
        'uuid-1',
        'uuid-1',
      ]);
      expect(sales.requests.map((r) => r.payment), const [
        SalePayment.cash(),
        SalePayment.mixed(cashUzs: 5000),
        SalePayment.mixed(cashUzs: 7000),
      ]);
      expect(minted, 1);
    },
  );

  test('cart is frozen and double-submit is ignored while in flight', () async {
    sales.gate = Completer<void>();
    sales.createResults.add(Right(saleFixture()));
    cubit.addProduct(cola);

    final first = cubit.checkout(PaymentMethod.cash);
    expect(cubit.state.isSubmitting, isTrue);
    expect(cubit.state.submittingMethod, PaymentMethod.cash);

    unawaited(cubit.checkout(PaymentMethod.cash)); // ignored
    cubit.addProduct(coffee); // ignored
    cubit.clearCart(); // ignored
    expect(cubit.state.cart.lines.single.product, cola);

    sales.gate!.complete();
    await first;
    expect(sales.requests, hasLength(1));
    expect(cubit.state.cart, Cart.empty);
  });

  test('empty cart never submits', () async {
    await cubit.checkout(PaymentMethod.cash);
    expect(sales.requests, isEmpty);
  });

  test(
    'BAR_PRODUCT_UNAVAILABLE reloads products and drops dead lines',
    () async {
      cubit
        ..addProduct(cola)
        ..addProduct(coffee);
      sales.createResults.add(
        Left(
          ServerFailure(
            message: 'unavailable',
            code: BarErrorCodes.productUnavailable,
            statusCode: 422,
          ),
        ),
      );
      products.products = [coffee, chips]; // cola was deactivated

      await cubit.checkout(PaymentMethod.cash);
      await pumpEventQueue();

      expect(products.calls, 2);
      expect(cubit.state.cart.lines.single.product, coffee);
      expect(cubit.state.cart.clientSaleId, isNull);
      final outcome = cubit.state.outcome;
      expect(outcome, isA<SaleFailed>());
      expect(
        ((outcome as SaleFailed).failure as ServerFailure).code,
        BarErrorCodes.productUnavailable,
      );
    },
  );

  test('each failure is a distinct outcome event (identity)', () async {
    sales.createResults
      ..add(Left(NoInternetFailure()))
      ..add(Left(NoInternetFailure()));
    cubit.addProduct(cola);
    await cubit.checkout(PaymentMethod.cash);
    final firstOutcome = cubit.state.outcome;
    await cubit.checkout(PaymentMethod.cash);
    expect(identical(cubit.state.outcome, firstOutcome), isFalse);
    expect(cubit.state.outcome == firstOutcome, isFalse);
  });

  test('a routine product refresh keeps the id of an unchanged cart', () async {
    sales.createResults.add(Left(NoInternetFailure()));
    cubit.addProduct(cola);
    await cubit.checkout(PaymentMethod.cash);
    await cubit.loadProducts();
    expect(cubit.state.cart.clientSaleId, 'uuid-1');
  });

  test('a failed product refresh keeps the catalog on screen', () async {
    products.failure = NoInternetFailure();
    await cubit.loadProducts();
    expect(cubit.state.productsStatus, ProductsStatus.failure);
    expect(cubit.state.products, hasLength(3));
  });
}
