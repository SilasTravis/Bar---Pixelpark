import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import 'bar_product.dart';

abstract class ProductsRepository {
  Future<Either<Failure, List<BarProduct>>> fetchProducts();
}
