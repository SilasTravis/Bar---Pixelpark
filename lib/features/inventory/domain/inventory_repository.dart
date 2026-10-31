import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import 'stock_item.dart';

enum StockBatchKind { receipt, writeoff, count }

abstract class InventoryRepository {
  /// `GET /bar/inventory/items` (or `/items/low` when [lowOnly]).
  Future<Either<Failure, StockPage>> fetchItems({
    String search = '',
    bool lowOnly = false,
    bool? active,
    int page = 1,
    int limit = 50,
  });

  Future<Either<Failure, StockItem>> createItem({
    required String name,
    required StockUnit unit,
    required int minQty,
  });

  Future<Either<Failure, StockItem>> updateItem(
    String id, {
    String? name,
    int? minQty,
    bool? active,
  });

  /// `POST /bar/inventory/{receipts|writeoffs|counts}`. [requestId] is the
  /// idempotency key, kept across retries. For counts [qty] is the counted
  /// absolute quantity.
  Future<Either<Failure, Unit>> submitBatch(
    StockBatchKind kind, {
    required String requestId,
    required String stockItemId,
    required int qty,
    String? reason,
  });

  Future<Either<Failure, MovementsPage>> fetchMovements({
    String? stockItemId,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, ProductSetup>> fetchSetup(String productId);

  Future<Either<Failure, ProductSetup>> saveSetup(ProductSetup setup);
}
