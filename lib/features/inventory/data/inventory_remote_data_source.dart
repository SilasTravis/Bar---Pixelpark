import 'package:dio/dio.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/utils/json_read.dart';
import '../domain/inventory_repository.dart';
import '../domain/stock_item.dart';

class InventoryRemoteDataSource {
  InventoryRemoteDataSource(this.dio);

  final Dio dio;

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e) {
      throw exceptionFromDio(e);
    }
  }

  Future<StockPage> fetchItems({
    String search = '',
    bool lowOnly = false,
    bool? active,
    int page = 1,
    int limit = 50,
  }) => _guard(() async {
    final term = search.trim();
    final response = await dio.get(
      lowOnly ? '/v1/bar/inventory/items/low' : '/v1/bar/inventory/items',
      queryParameters: {
        if (!lowOnly && term.isNotEmpty) 'search': term,
        if (!lowOnly && active != null) 'active': active,
        'page': page,
        'limit': limit,
      },
    );
    return StockPage.fromJson(readMap(response.data));
  });

  Future<StockItem> createItem({
    required String name,
    required StockUnit unit,
    required int minQty,
  }) => _guard(() async {
    final response = await dio.post(
      '/v1/bar/inventory/items',
      data: {'name': name.trim(), 'unit': unit.apiValue, 'minQty': minQty},
    );
    return StockItem.fromJson(readMap(response.data));
  });

  Future<StockItem> updateItem(
    String id, {
    String? name,
    int? minQty,
    bool? active,
  }) => _guard(() async {
    final response = await dio.patch(
      '/v1/bar/inventory/items/$id',
      data: {'name': ?name?.trim(), 'minQty': ?minQty, 'active': ?active},
    );
    return StockItem.fromJson(readMap(response.data));
  });

  /// Safe to re-send: the body carries [requestId], which the backend
  /// replays instead of applying twice.
  Future<void> submitBatch(
    StockBatchKind kind, {
    required String requestId,
    required String stockItemId,
    required int qty,
    String? reason,
  }) => _guard(() async {
    final path = switch (kind) {
      StockBatchKind.receipt => 'receipts',
      StockBatchKind.writeoff => 'writeoffs',
      StockBatchKind.count => 'counts',
    };
    final trimmed = reason?.trim();
    await dio.post(
      '/v1/bar/inventory/$path',
      data: {
        'requestId': requestId,
        if (trimmed != null && trimmed.isNotEmpty) 'reason': trimmed,
        'lines': [
          {'stockItemId': stockItemId, 'qty': qty},
        ],
      },
    );
  });

  Future<MovementsPage> fetchMovements({
    String? stockItemId,
    int page = 1,
    int limit = 20,
  }) => _guard(() async {
    final response = await dio.get(
      '/v1/bar/inventory/movements',
      queryParameters: {
        'page': page,
        'limit': limit,
        'stockItemId': ?stockItemId,
      },
    );
    return MovementsPage.fromJson(readMap(response.data));
  });

  Future<ProductSetup> fetchSetup(String productId) => _guard(() async {
    final response = await dio.get(
      '/v1/bar/inventory/products/$productId/setup',
    );
    return ProductSetup.fromJson(productId, readMap(response.data));
  });

  Future<ProductSetup> saveSetup(ProductSetup setup) => _guard(() async {
    final response = await dio.put(
      '/v1/bar/inventory/products/${setup.productId}/setup',
      data: setup.toRequest(),
    );
    return ProductSetup.fromJson(setup.productId, readMap(response.data));
  });
}
