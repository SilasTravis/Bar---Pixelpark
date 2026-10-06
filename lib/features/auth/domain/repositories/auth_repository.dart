import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/bar_cashier.dart';

abstract class AuthRepository {
  Future<Either<Failure, BarCashier>> login({
    required String username,
    required String password,
  });

  /// `GET /v1/bar/auth/me` — refreshes the cached cashier + bar.
  Future<Either<Failure, BarCashier>> getCurrentCashier();

  /// The cashier cached at the last login / `me`, if any.
  BarCashier? cachedCashier();

  /// Best-effort server logout, then the local session is always cleared.
  Future<void> logout();

  /// Drops the local session without calling the server (the account was
  /// deactivated, the refresh token was rejected).
  Future<void> clearLocalSession();
}
