import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import 'bar_sale.dart';
import 'cart.dart';

abstract class SalesRepository {
  /// `POST /v1/bar/sales`. [cart] must already carry its `clientSaleId`.
  Future<Either<Failure, BarSale>> createSale({
    required Cart cart,
    required SalePayment payment,
  });

  /// `GET /v1/bar/sales`: the open shift's sales, newest first.
  Future<Either<Failure, List<BarSale>>> fetchShiftSales();

  Future<Either<Failure, BarSale>> refund(String saleId, {String? reason});
}
