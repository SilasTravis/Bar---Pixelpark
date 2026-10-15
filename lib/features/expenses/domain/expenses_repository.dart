import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import 'bar_expense.dart';

abstract class ExpensesRepository {
  /// `GET /v1/bar/expenses`: the open shift's expenses, newest first
  /// (empty when no shift is open).
  Future<Either<Failure, List<BarExpense>>> fetchShiftExpenses();

  /// `POST /v1/bar/expenses`. [clientExpenseId] is the idempotency key: a
  /// repeat with the same id returns the already-recorded expense.
  Future<Either<Failure, BarExpense>> create({
    required String clientExpenseId,
    required String name,
    required int amountUzs,
    required ExpensePaidFrom paidFrom,
    String? note,
  });

  /// `DELETE /v1/bar/expenses/:id` (own expense, open shift only).
  Future<Either<Failure, Unit>> delete(String expenseId);

  /// `GET /v1/bar/expenses/suggestions`: most-used names of this bar.
  Future<Either<Failure, List<ExpenseSuggestion>>> fetchSuggestions();
}
