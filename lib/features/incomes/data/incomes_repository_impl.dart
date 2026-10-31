import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../domain/bar_income.dart';
import '../domain/incomes_repository.dart';
import 'incomes_remote_data_source.dart';

class IncomesRepositoryImpl implements IncomesRepository {
  IncomesRepositoryImpl(this.remote);

  final IncomesRemoteDataSource remote;

  @override
  Future<Either<Failure, List<BarIncome>>> fetchShiftIncomes() =>
      guardFailures(remote.fetchShiftIncomes);

  @override
  Future<Either<Failure, BarIncome>> create({
    required String clientIncomeId,
    required String name,
    required int amountUzs,
    required IncomeReceivedTo receivedTo,
    String? note,
  }) => guardFailures(
    () => remote.create(
      clientIncomeId: clientIncomeId,
      name: name,
      amountUzs: amountUzs,
      receivedTo: receivedTo,
      note: note,
    ),
  );

  @override
  Future<Either<Failure, Unit>> delete(String incomeId) =>
      guardFailures(() async {
        await remote.delete(incomeId);
        return unit;
      });

  @override
  Future<Either<Failure, List<IncomeSuggestion>>> fetchSuggestions() =>
      guardFailures(remote.fetchSuggestions);
}
