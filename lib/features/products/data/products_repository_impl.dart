import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../domain/bar_product.dart';
import '../domain/products_repository.dart';
import 'products_remote_data_source.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this.remote);

  final ProductsRemoteDataSource remote;

  @override
  Future<Either<Failure, List<BarProduct>>> fetchProducts() =>
      guardFailures(remote.fetchProducts);
}
