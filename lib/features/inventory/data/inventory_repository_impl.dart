import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../domain/inventory_repository.dart';
import '../domain/stock_item.dart';
import 'inventory_remote_data_source.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl(this.remote);

  final InventoryRemoteDataSource remote;

  @override
  Future<Either<Failure, StockPage>> fetchItems({
    String search = '',
    bool lowOnly = false,
    bool? active,
    int page = 1,
    int limit = 50,
  }) => guardFailures(
    () => remote.fetchItems(
      search: search,
      lowOnly: lowOnly,
      active: active,
      page: page,
      limit: limit,
    ),
  );

  @override
  Future<Either<Failure, StockItem>> createItem({
    required String name,
    required StockUnit unit,
    required int minQty,
  }) => guardFailures(
    () => remote.createItem(name: name, unit: unit, minQty: minQty),
  );

  @override
  Future<Either<Failure, StockItem>> updateItem(
    String id, {
    String? name,
    int? minQty,
    bool? active,
  }) => guardFailures(
    () => remote.updateItem(id, name: name, minQty: minQty, active: active),
  );

  @override
  Future<Either<Failure, Unit>> submitBatch(
    StockBatchKind kind, {
    required String requestId,
    required String stockItemId,
    required int qty,
    String? reason,
    int? costUzs,
  }) => guardFailures(() async {
    await remote.submitBatch(
      kind,
      requestId: requestId,
      stockItemId: stockItemId,
      qty: qty,
      reason: reason,
      costUzs: costUzs,
    );
    return unit;
  });

  @override
  Future<Either<Failure, MovementsPage>> fetchMovements({
    String? stockItemId,
    int page = 1,
    int limit = 20,
  }) => guardFailures(
    () => remote.fetchMovements(
      stockItemId: stockItemId,
      page: page,
      limit: limit,
    ),
  );

  @override
  Future<Either<Failure, ProductSetup>> fetchSetup(String productId) =>
      guardFailures(() => remote.fetchSetup(productId));

  @override
  Future<Either<Failure, ProductSetup>> saveSetup(ProductSetup setup) =>
      guardFailures(() => remote.saveSetup(setup));
}
