import 'package:dio/dio.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/utils/json_read.dart';
import '../domain/bar_product.dart';

abstract class ProductsRemoteDataSource {
  /// `GET /v1/bar/products` → `{ items: BarProduct[] }`: the active products
  /// of the cashier's bar, ordered by `sortOrder, name`.
  Future<List<BarProduct>> fetchProducts();
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  ProductsRemoteDataSourceImpl(this.dio);

  final Dio dio;

  @override
  Future<List<BarProduct>> fetchProducts() async {
    try {
      final response = await dio.get('/v1/bar/products');
      return readMapList(
        readMap(response.data)['items'],
      ).map(BarProduct.fromJson).toList();
    } on DioException catch (e) {
      throw exceptionFromDio(e);
    }
  }
}
