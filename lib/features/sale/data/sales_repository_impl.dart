import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../domain/bar_sale.dart';
import '../domain/cart.dart';
import '../domain/sales_repository.dart';
import 'sales_remote_data_source.dart';

class SalesRepositoryImpl implements SalesRepository {
  SalesRepositoryImpl(this.remote);

  final SalesRemoteDataSource remote;

  @override
  Future<Either<Failure, BarSale>> createSale({
    required Cart cart,
    required PaymentMethod paymentMethod,
  }) {
    final clientSaleId = cart.clientSaleId;
    if (clientSaleId == null) {
      throw ArgumentError('A cart must carry its clientSaleId when submitted');
    }
    return guardFailures(
      () => remote.createSale(
        clientSaleId: clientSaleId,
        paymentMethod: paymentMethod,
        items: cart.toRequestItems(),
      ),
    );
  }

  @override
  Future<Either<Failure, List<BarSale>>> fetchShiftSales() =>
      guardFailures(remote.fetchShiftSales);

  @override
  Future<Either<Failure, BarSale>> refund(String saleId, {String? reason}) =>
      guardFailures(() => remote.refund(saleId, reason: reason));
}
