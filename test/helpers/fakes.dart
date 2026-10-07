import 'dart:async';
import 'dart:collection';

import 'package:bar_app/core/error/failure.dart';
import 'package:bar_app/features/auth/domain/entities/bar_cashier.dart';
import 'package:bar_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bar_app/features/products/domain/bar_product.dart';
import 'package:bar_app/features/products/domain/products_repository.dart';
import 'package:bar_app/features/sale/domain/bar_sale.dart';
import 'package:bar_app/features/sale/domain/cart.dart';
import 'package:bar_app/features/sale/domain/sales_repository.dart';
import 'package:bar_app/features/shift/domain/bar_shift.dart';
import 'package:bar_app/features/shift/domain/shift_repository.dart';
import 'package:dartz/dartz.dart';

class FakeProductsRepository implements ProductsRepository {
  FakeProductsRepository(this.products);

  List<BarProduct> products;
  Failure? failure;
  int calls = 0;

  @override
  Future<Either<Failure, List<BarProduct>>> fetchProducts() async {
    calls++;
    final f = failure;
    return f != null ? Left(f) : Right(products);
  }
}

/// One recorded `POST /v1/bar/sales`.
class SaleRequest {
  SaleRequest(this.clientSaleId, this.payment, this.items);

  final String clientSaleId;
  final SalePayment payment;
  final List<Map<String, dynamic>> items;

  PaymentMethod get method => payment.method;
}

class FakeSalesRepository implements SalesRepository {
  /// Queued answers for createSale, consumed in order.
  final Queue<Either<Failure, BarSale>> createResults = Queue();
  final List<SaleRequest> requests = [];

  /// When set, createSale waits for it (to observe the in-flight state).
  Completer<void>? gate;

  @override
  Future<Either<Failure, BarSale>> createSale({
    required Cart cart,
    required SalePayment payment,
  }) async {
    requests.add(
      SaleRequest(cart.clientSaleId!, payment, cart.toRequestItems()),
    );
    if (gate != null) await gate!.future;
    return createResults.removeFirst();
  }

  /// What `GET /v1/bar/sales` answers.
  List<BarSale> shiftSales = const [];

  @override
  Future<Either<Failure, List<BarSale>>> fetchShiftSales() async =>
      Right(shiftSales);

  @override
  Future<Either<Failure, BarSale>> refund(String saleId, {String? reason}) =>
      throw UnimplementedError();
}

class FakeShiftRepository implements ShiftRepository {
  final Queue<Either<Failure, BarShift?>> currentResults = Queue();
  final Queue<Either<Failure, BarShift>> openResults = Queue();
  final Queue<Either<Failure, BarShift>> closeResults = Queue();
  final List<int> closedWith = [];

  @override
  Future<Either<Failure, BarShift?>> fetchCurrent() async =>
      currentResults.removeFirst();

  @override
  Future<Either<Failure, BarShift>> open() async => openResults.removeFirst();

  @override
  Future<Either<Failure, BarShift>> close({
    required int countedCashUzs,
    String? note,
  }) async {
    closedWith.add(countedCashUzs);
    return closeResults.removeFirst();
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this.cashier);

  final BarCashier? cashier;
  bool loggedOut = false;

  @override
  BarCashier? cachedCashier() => cashier;

  @override
  Future<Either<Failure, BarCashier>> getCurrentCashier() async =>
      Right(cashier!);

  @override
  Future<Either<Failure, BarCashier>> login({
    required String username,
    required String password,
  }) async => Right(cashier!);

  @override
  Future<void> logout() async => loggedOut = true;

  @override
  Future<void> clearLocalSession() async => loggedOut = true;
}
