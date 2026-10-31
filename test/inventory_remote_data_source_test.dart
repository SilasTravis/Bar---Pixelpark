import 'package:bar_app/features/inventory/data/inventory_remote_data_source.dart';
import 'package:bar_app/features/inventory/domain/inventory_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<({String path, Map<String, dynamic> body})> send(
    StockBatchKind kind, {
    int? costUzs,
  }) async {
    late String path;
    late Map<String, dynamic> body;
    final dio = Dio(BaseOptions(baseUrl: 'https://bar.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          path = options.path;
          body = Map<String, dynamic>.from(options.data as Map);
          handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ),
    );
    await InventoryRemoteDataSource(dio).submitBatch(
      kind,
      requestId: 'req-12345678',
      stockItemId: 'item-1',
      qty: 1800,
      costUzs: costUzs,
    );
    return (path: path, body: body);
  }

  test(
    'a count line is sent as countedQty (the backend rejects qty)',
    () async {
      final r = await send(StockBatchKind.count);
      expect(r.path, '/v1/bar/inventory/counts');
      expect((r.body['lines'] as List).single, {
        'stockItemId': 'item-1',
        'countedQty': 1800,
      });
    },
  );

  test('a kirim line carries costUzs; other kinds and zero never do', () async {
    final r = await send(StockBatchKind.receipt, costUzs: 100000);
    expect((r.body['lines'] as List).single, {
      'stockItemId': 'item-1',
      'qty': 1800,
      'costUzs': 100000,
    });
    for (final other in [
      await send(StockBatchKind.receipt, costUzs: 0),
      await send(StockBatchKind.writeoff, costUzs: 5000),
    ]) {
      expect((other.body['lines'] as List).single, isNot(contains('costUzs')));
    }
  });

  test('receipt and writeoff lines keep qty', () async {
    for (final kind in [StockBatchKind.receipt, StockBatchKind.writeoff]) {
      final r = await send(kind);
      expect((r.body['lines'] as List).single, {
        'stockItemId': 'item-1',
        'qty': 1800,
      });
    }
  });
}
