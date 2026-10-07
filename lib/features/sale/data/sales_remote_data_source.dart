import 'package:dio/dio.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/utils/json_read.dart';
import '../domain/bar_sale.dart';

abstract class SalesRemoteDataSource {
  Future<BarSale> createSale({
    required String clientSaleId,
    required SalePayment payment,
    required List<Map<String, dynamic>> items,
  });
  Future<List<BarSale>> fetchShiftSales();
  Future<BarSale> refund(String saleId, {String? reason});
}

class SalesRemoteDataSourceImpl implements SalesRemoteDataSource {
  SalesRemoteDataSourceImpl(this.dio);

  final Dio dio;

  @override
  Future<BarSale> createSale({
    required String clientSaleId,
    required SalePayment payment,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await dio.post(
        '/v1/bar/sales',
        data: {
          'clientSaleId': clientSaleId,
          ...payment.toRequestFields(),
          'items': items,
        },
      );
      return BarSale.fromJson(readMap(response.data));
    } on DioException catch (e) {
      throw exceptionFromDio(e);
    }
  }

  @override
  Future<List<BarSale>> fetchShiftSales() async {
    try {
      final response = await dio.get('/v1/bar/sales');
      return readMapList(
        readMap(response.data)['items'],
      ).map(BarSale.fromJson).toList();
    } on DioException catch (e) {
      throw exceptionFromDio(e);
    }
  }

  @override
  Future<BarSale> refund(String saleId, {String? reason}) async {
    try {
      final response = await dio.post(
        '/v1/bar/sales/${Uri.encodeComponent(saleId)}/refund',
        data: {
          if (reason != null && reason.trim().isNotEmpty)
            'reason': reason.trim(),
        },
      );
      return BarSale.fromJson(readMap(response.data));
    } on DioException catch (e) {
      throw exceptionFromDio(e);
    }
  }
}
