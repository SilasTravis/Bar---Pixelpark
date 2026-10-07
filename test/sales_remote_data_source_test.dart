import 'package:bar_app/features/sale/data/sales_remote_data_source.dart';
import 'package:bar_app/features/sale/domain/bar_sale.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures every request body and answers with a canned sale.
Dio _capturingDio(List<Map<String, dynamic>> bodies) {
  final dio = Dio(BaseOptions(baseUrl: 'https://bar.test'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final body = Map<String, dynamic>.from(options.data as Map);
        bodies.add(body);
        final method = body['paymentMethod'] as String;
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 201,
            data: {
              'id': 's-1',
              'receiptNo': 5,
              'bar': {'id': 'bar-1', 'name': 'Bar'},
              'shiftId': 'sh-1',
              'cashierId': 'c-1',
              'cashierName': 'Aziz',
              'paymentMethod': method,
              'totalUzs': 44000,
              'cashUzs': switch (method) {
                'mixed' => body['cashUzs'],
                'cash' => 44000,
                _ => 0,
              },
              'cardUzs': switch (method) {
                'mixed' => 44000 - (body['cashUzs'] as int),
                'card' => 44000,
                _ => 0,
              },
              'status': 'completed',
              'createdAt': '2026-10-07T09:00:00.000Z',
              'items': <dynamic>[],
            },
          ),
        );
      },
    ),
  );
  return dio;
}

void main() {
  const items = [
    {'productId': 'p-cola', 'quantity': 2},
  ];

  test('mixed sends paymentMethod mixed + cashUzs', () async {
    final bodies = <Map<String, dynamic>>[];
    final remote = SalesRemoteDataSourceImpl(_capturingDio(bodies));
    final sale = await remote.createSale(
      clientSaleId: 'uuid-1',
      payment: const SalePayment.mixed(cashUzs: 30000),
      items: items,
    );
    expect(bodies.single, {
      'clientSaleId': 'uuid-1',
      'paymentMethod': 'mixed',
      'cashUzs': 30000,
      'items': items,
    });
    expect(sale.paymentMethod, PaymentMethod.mixed);
    expect(sale.cashUzs, 30000);
    expect(sale.cardUzs, 14000);
  });

  test('cash and card never send cashUzs', () async {
    final bodies = <Map<String, dynamic>>[];
    final remote = SalesRemoteDataSourceImpl(_capturingDio(bodies));
    for (final payment in const [SalePayment.cash(), SalePayment.card()]) {
      await remote.createSale(
        clientSaleId: 'uuid-1',
        payment: payment,
        items: items,
      );
    }
    expect(bodies.map((b) => b['paymentMethod']), ['cash', 'card']);
    for (final body in bodies) {
      expect(body.containsKey('cashUzs'), isFalse);
      expect(
        body.keys,
        unorderedEquals(['clientSaleId', 'paymentMethod', 'items']),
      );
    }
  });

  test('SalePayment request fields', () {
    expect(const SalePayment.cash().toRequestFields(), {
      'paymentMethod': 'cash',
    });
    expect(const SalePayment.card().toRequestFields(), {
      'paymentMethod': 'card',
    });
    expect(const SalePayment.mixed(cashUzs: 1).toRequestFields(), {
      'paymentMethod': 'mixed',
      'cashUzs': 1,
    });
  });
}
