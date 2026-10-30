import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import 'bar_income.dart';

abstract class IncomesRepository {
  /// `GET /v1/bar/incomes`: the open shift's incomes, newest first
  /// (empty when no shift is open).
  Future<Either<Failure, List<BarIncome>>> fetchShiftIncomes();

  /// `POST /v1/bar/incomes`. [clientIncomeId] is the idempotency key: a
  /// repeat with the same id returns the already-recorded income.
  Future<Either<Failure, BarIncome>> create({
    required String clientIncomeId,
    required String name,
    required int amountUzs,
    required IncomeReceivedTo receivedTo,
    String? note,
  });

  /// `DELETE /v1/bar/incomes/:id` (own income, open shift only).
  Future<Either<Failure, Unit>> delete(String incomeId);

  /// `GET /v1/bar/incomes/suggestions`: most-used names of this bar.
  Future<Either<Failure, List<IncomeSuggestion>>> fetchSuggestions();
}
