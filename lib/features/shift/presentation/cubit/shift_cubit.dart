import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/bar_shift.dart';
import '../../domain/shift_repository.dart';

enum ShiftStatus { loading, none, open, failure }

class ShiftState extends Equatable {
  const ShiftState({
    this.status = ShiftStatus.loading,
    this.shift,
    this.failure,
    this.isOpening = false,
  });

  final ShiftStatus status;

  /// The open shift (with live totals) while [status] is `open`.
  final BarShift? shift;

  /// Why the last load or open failed.
  final Failure? failure;
  final bool isOpening;

  @override
  List<Object?> get props => [status, shift, failure, isOpening];
}

/// Owns "is there an open shift": decides between the open-shift screen
/// and the sale screen, and holds the totals shown in the header and on the
/// close-shift screen.
class ShiftCubit extends Cubit<ShiftState> {
  ShiftCubit(this._repository) : super(const ShiftState());

  final ShiftRepository _repository;

  /// `GET /v1/bar/shifts/current`. While a shift is already open this
  /// refreshes it in place (no spinner), so the sale screen underneath —
  /// and its cart — is never torn down by a background refresh.
  Future<void> load() async {
    final hadShift = state.status == ShiftStatus.open;
    if (!hadShift) _emit(const ShiftState());
    final result = await _repository.fetchCurrent();
    result.fold(
      (failure) => _emit(
        hadShift
            // Keep showing the known shift; a failed background refresh is
            // not a reason to block selling.
            ? ShiftState(status: ShiftStatus.open, shift: state.shift)
            : ShiftState(status: ShiftStatus.failure, failure: failure),
      ),
      (shift) => _emit(
        shift == null
            ? const ShiftState(status: ShiftStatus.none)
            : ShiftState(status: ShiftStatus.open, shift: shift),
      ),
    );
  }

  Future<void> openShift() async {
    if (state.isOpening) return;
    _emit(
      ShiftState(status: state.status, shift: state.shift, isOpening: true),
    );
    final result = await _repository.open();
    await result.fold(
      (failure) async {
        if (failure is ServerFailure &&
            failure.code == BarErrorCodes.shiftAlreadyOpen) {
          // Opened from another session/device meanwhile — just pick it up.
          _emit(const ShiftState(status: ShiftStatus.none));
          await load();
          return;
        }
        _emit(ShiftState(status: state.status, failure: failure));
      },
      (shift) async =>
          _emit(ShiftState(status: ShiftStatus.open, shift: shift)),
    );
  }

  /// `POST /v1/bar/shifts/close`. On success the app returns to the
  /// open-shift screen; the closed shift (with the server's final totals and
  /// cash difference) is returned for the summary.
  Future<Either<Failure, BarShift>> closeShift({
    required int countedCashUzs,
    String? note,
  }) async {
    final result = await _repository.close(
      countedCashUzs: countedCashUzs,
      note: note,
    );
    result.fold((failure) {
      if (failure is ServerFailure &&
          failure.code == BarErrorCodes.shiftNotOpen) {
        // Already closed (e.g. by another session): reflect reality.
        _emit(const ShiftState(status: ShiftStatus.none));
      }
    }, (_) => _emit(const ShiftState(status: ShiftStatus.none)));
    return result;
  }

  /// A sale was refused with `BAR_SHIFT_NOT_OPEN`: go to the open-shift
  /// screen.
  void markNoShift() => _emit(const ShiftState(status: ShiftStatus.none));

  void _emit(ShiftState next) {
    if (!isClosed) emit(next);
  }
}
