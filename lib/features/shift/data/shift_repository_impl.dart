import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../domain/bar_shift.dart';
import '../domain/shift_repository.dart';
import 'shift_remote_data_source.dart';

class ShiftRepositoryImpl implements ShiftRepository {
  ShiftRepositoryImpl(this.remote);

  final ShiftRemoteDataSource remote;

  @override
  Future<Either<Failure, BarShift?>> fetchCurrent() =>
      guardFailures(remote.fetchCurrent);

  @override
  Future<Either<Failure, BarShift>> open() => guardFailures(remote.open);

  @override
  Future<Either<Failure, BarShift>> close({
    required int countedCashUzs,
    String? note,
  }) => guardFailures(
    () => remote.close(countedCashUzs: countedCashUzs, note: note),
  );
}
