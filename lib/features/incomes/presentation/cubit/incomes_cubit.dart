import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failure.dart';
import '../../domain/bar_income.dart';
import '../../domain/incomes_repository.dart';

enum IncomesStatus { loading, loaded, failure }

class IncomesState extends Equatable {
  const IncomesState({
    this.status = IncomesStatus.loading,
    this.incomes = const [],
    this.suggestions = const [],
    this.failure,
  });

  final IncomesStatus status;

  /// The open shift's incomes, newest first (server order).
  final List<BarIncome> incomes;

  /// Quick-add chips; empty when the server has none or could not answer.
  final List<IncomeSuggestion> suggestions;
  final Failure? failure;

  int get totalUzs => incomeTotalsOf(incomes).totalUzs;

  /// The part put into the cash drawer.
  int get cashUzs => incomeTotalsOf(incomes).cashUzs;

  IncomesState copyWith({
    IncomesStatus? status,
    List<BarIncome>? incomes,
    List<IncomeSuggestion>? suggestions,
    Failure? failure,
  }) => IncomesState(
    status: status ?? this.status,
    incomes: incomes ?? this.incomes,
    suggestions: suggestions ?? this.suggestions,
    failure: failure,
  );

  @override
  List<Object?> get props => [status, incomes, suggestions, failure];
}

/// "Kirimlar": the open shift's incomes, adding and deleting them.
class IncomesCubit extends Cubit<IncomesState> {
  IncomesCubit(this._repository, {String Function()? newClientIncomeId})
    : _newClientIncomeId = newClientIncomeId ?? _uuidV4,
      super(const IncomesState());

  final IncomesRepository _repository;
  final String Function() _newClientIncomeId;

  static String _uuidV4() => const Uuid().v4();

  /// A fresh idempotency key. The new-income dialog takes one when it opens
  /// and keeps it across retries, so a re-sent save cannot record twice.
  String newClientIncomeId() => _newClientIncomeId();

  Future<void> load() async {
    _emit(state.copyWith(status: IncomesStatus.loading));
    final result = await _repository.fetchShiftIncomes();
    result.fold(
      (failure) => _emit(
        state.copyWith(status: IncomesStatus.failure, failure: failure),
      ),
      (incomes) =>
          _emit(state.copyWith(status: IncomesStatus.loaded, incomes: incomes)),
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

  /// `POST /v1/bar/incomes`. The saved income goes on top of the list (a
  /// replayed id answers with an already-listed income, which is replaced
  /// rather than duplicated).
  Future<Either<Failure, BarIncome>> add({
    required String clientIncomeId,
    required String name,
    required int amountUzs,
    required IncomeReceivedTo receivedTo,
    String? note,
  }) async {
    final result = await _repository.create(
      clientIncomeId: clientIncomeId,
      name: name,
      amountUzs: amountUzs,
      receivedTo: receivedTo,
      note: note,
    );
    result.fold(
      (_) {},
      (saved) => _emit(
        state.copyWith(
          status: IncomesStatus.loaded,
          incomes: [saved, ...state.incomes.where((e) => e.id != saved.id)],
        ),
      ),
    );
    // The chips' "last amount" may have changed.
    if (result.isRight()) loadSuggestions();
    return result;
  }

  /// `DELETE /v1/bar/incomes/:id`. `BAR_INCOME_NOT_FOUND` means the list
  /// is stale (already deleted, or the shift was closed), so it is reloaded.
  Future<Either<Failure, Unit>> delete(String incomeId) async {
    final result = await _repository.delete(incomeId);
    result.fold(
      (failure) {
        if (failure is ServerFailure &&
            failure.code == BarErrorCodes.incomeNotFound) {
          load();
        }
      },
      (_) => _emit(
        state.copyWith(
          status: IncomesStatus.loaded,
          incomes: state.incomes.where((e) => e.id != incomeId).toList(),
        ),
      ),
    );
    return result;
  }

  void _emit(IncomesState next) {
    if (!isClosed) emit(next);
  }
}
