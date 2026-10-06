import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import 'bar_shift.dart';

abstract class ShiftRepository {
  /// Right(null) = no open shift.
  Future<Either<Failure, BarShift?>> fetchCurrent();
  Future<Either<Failure, BarShift>> open();
  Future<Either<Failure, BarShift>> close({
    required int countedCashUzs,
    String? note,
  });
}
