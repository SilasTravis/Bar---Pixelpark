import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../domain/bar_expense.dart';
import '../domain/expenses_repository.dart';
import 'expenses_remote_data_source.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  ExpensesRepositoryImpl(this.remote);

  final ExpensesRemoteDataSource remote;

  @override
  Future<Either<Failure, List<BarExpense>>> fetchShiftExpenses() =>
      guardFailures(remote.fetchShiftExpenses);

  @override
  Future<Either<Failure, BarExpense>> create({
    required String clientExpenseId,
    required String name,
    required int amountUzs,
    required ExpensePaidFrom paidFrom,
    String? note,
  }) => guardFailures(
    () => remote.create(
      clientExpenseId: clientExpenseId,
      name: name,
      amountUzs: amountUzs,
      paidFrom: paidFrom,
      note: note,
    ),
  );

  @override
  Future<Either<Failure, Unit>> delete(String expenseId) =>
      guardFailures(() async {
        await remote.delete(expenseId);
        return unit;
      });

  @override
  Future<Either<Failure, List<ExpenseSuggestion>>> fetchSuggestions() =>
      guardFailures(remote.fetchSuggestions);
}
