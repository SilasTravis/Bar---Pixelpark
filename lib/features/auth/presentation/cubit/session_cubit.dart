import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/bar_cashier.dart';
import '../../domain/repositories/auth_repository.dart';

class SessionState extends Equatable {
  const SessionState({this.cashier, this.ended = false});

  /// Who is signed in, and at which bar (cached, then refreshed by `me`).
  final BarCashier? cashier;

  /// The session is over (logout, or the account/bar was deactivated):
  /// the UI returns to the login screen.
  final bool ended;

  @override
  List<Object?> get props => [cashier, ended];
}

class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._repository)
    : super(SessionState(cashier: _repository.cachedCashier()));

  final AuthRepository _repository;

  /// `GET /v1/bar/auth/me` on start. A deactivated cashier or bar ends the
  /// session; a network failure keeps the cached identity (the shift check
  /// that runs alongside reports connectivity problems).
  Future<void> refresh() async {
    final result = await _repository.getCurrentCashier();
    await result.fold((failure) async {
      if (isAccountBlocked(failure) ||
          (failure is ServerFailure && failure.statusCode == 401)) {
        await endBecauseBlocked();
      }
    }, (cashier) async => _emit(SessionState(cashier: cashier)));
  }

  Future<void> logout() async {
    await _repository.logout();
    _emit(SessionState(cashier: state.cashier, ended: true));
  }

  /// Any request answered with `BAR_CASHIER_INACTIVE` / `BAR_INACTIVE`.
  Future<void> endBecauseBlocked() async {
    await _repository.clearLocalSession();
    _emit(SessionState(cashier: state.cashier, ended: true));
  }

  void _emit(SessionState next) {
    if (!isClosed) emit(next);
  }
}
