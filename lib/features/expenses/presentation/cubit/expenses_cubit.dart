import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failure.dart';
import '../../domain/bar_expense.dart';
import '../../domain/expenses_repository.dart';

enum ExpensesStatus { loading, loaded, failure }

class ExpensesState extends Equatable {
  const ExpensesState({
    this.status = ExpensesStatus.loading,
    this.expenses = const [],
    this.suggestions = const [],
    this.failure,
  });

  final ExpensesStatus status;

  /// The open shift's expenses, newest first (server order).
  final List<BarExpense> expenses;

  /// Quick-add chips; empty when the server has none or could not answer.
  final List<ExpenseSuggestion> suggestions;
  final Failure? failure;

  int get totalUzs => expenseTotalsOf(expenses).totalUzs;

  /// The part taken from the cash drawer.
  int get cashUzs => expenseTotalsOf(expenses).cashUzs;

  ExpensesState copyWith({
    ExpensesStatus? status,
    List<BarExpense>? expenses,
    List<ExpenseSuggestion>? suggestions,
    Failure? failure,
  }) => ExpensesState(
    status: status ?? this.status,
    expenses: expenses ?? this.expenses,
    suggestions: suggestions ?? this.suggestions,
    failure: failure,
  );

  @override
  List<Object?> get props => [status, expenses, suggestions, failure];
}

/// "Chiqimlar": the open shift's expenses, adding and deleting them.
class ExpensesCubit extends Cubit<ExpensesState> {
  ExpensesCubit(this._repository, {String Function()? newClientExpenseId})
    : _newClientExpenseId = newClientExpenseId ?? _uuidV4,
      super(const ExpensesState());

  final ExpensesRepository _repository;
  final String Function() _newClientExpenseId;

  static String _uuidV4() => const Uuid().v4();

  /// A fresh idempotency key. The new-expense dialog takes one when it opens
  /// and keeps it across retries, so a re-sent save cannot record twice.
  String newClientExpenseId() => _newClientExpenseId();

  Future<void> load() async {
    _emit(state.copyWith(status: ExpensesStatus.loading));
    final result = await _repository.fetchShiftExpenses();
    result.fold(
      (failure) => _emit(
        state.copyWith(status: ExpensesStatus.failure, failure: failure),
      ),
      (expenses) => _emit(
        state.copyWith(status: ExpensesStatus.loaded, expenses: expenses),
      ),
    );
  }

  /// Suggestions are a convenience: a failure just leaves the chips out.
  Future<void> loadSuggestions() async {
    final result = await _repository.fetchSuggestions();
    result.fold(
      (_) {},
      (suggestions) => _emit(
        state.copyWith(suggestions: suggestions, failure: state.failure),
      ),
    );
  }

  /// `POST /v1/bar/expenses`. The saved expense goes on top of the list (a
  /// replayed id answers with an already-listed expense, which is replaced
  /// rather than duplicated).
  Future<Either<Failure, BarExpense>> add({
    required String clientExpenseId,
    required String name,
    required int amountUzs,
    required ExpensePaidFrom paidFrom,
    String? note,
  }) async {
    final result = await _repository.create(
      clientExpenseId: clientExpenseId,
      name: name,
      amountUzs: amountUzs,
      paidFrom: paidFrom,
      note: note,
    );
    result.fold(
      (_) {},
      (saved) => _emit(
        state.copyWith(
          status: ExpensesStatus.loaded,
          expenses: [saved, ...state.expenses.where((e) => e.id != saved.id)],
        ),
      ),
    );
    // The chips' "last amount" may have changed.
    if (result.isRight()) loadSuggestions();
    return result;
  }

  /// `DELETE /v1/bar/expenses/:id`. `BAR_EXPENSE_NOT_FOUND` means the list
  /// is stale (already deleted, or the shift was closed), so it is reloaded.
  Future<Either<Failure, Unit>> delete(String expenseId) async {
    final result = await _repository.delete(expenseId);
    result.fold(
      (failure) {
        if (failure is ServerFailure &&
            failure.code == BarErrorCodes.expenseNotFound) {
          load();
        }
      },
      (_) => _emit(
        state.copyWith(
          status: ExpensesStatus.loaded,
          expenses: state.expenses.where((e) => e.id != expenseId).toList(),
        ),
      ),
    );
    return result;
  }

  void _emit(ExpensesState next) {
    if (!isClosed) emit(next);
  }
}
