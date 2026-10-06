import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/local_source/local_source.dart';
import '../../domain/entities/bar_cashier.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.remoteDataSource, this.localSource);

  final AuthRemoteDataSource remoteDataSource;
  final LocalSource localSource;

  @override
  Future<Either<Failure, BarCashier>> login({
    required String username,
    required String password,
  }) => guardFailures(() async {
    final response = await remoteDataSource.login(
      username: username,
      password: password,
    );
    localSource.setAccessToken(response.tokens.accessToken);
    localSource.setRefreshToken(response.tokens.refreshToken);
    _saveCashier(response.cashier);
    return response.cashier;
  });

  @override
  Future<Either<Failure, BarCashier>> getCurrentCashier() =>
      guardFailures(() async {
        final cashier = await remoteDataSource.getMe();
        _saveCashier(cashier);
        return cashier;
      });

  @override
  BarCashier? cachedCashier() {
    final id = localSource.getCashierId();
    if (id == null) return null;
    return BarCashier(
      id: id,
      fullName: localSource.getCashierFullName() ?? '',
      username: localSource.getCashierUsername() ?? '',
      bar: BarRef(
        id: localSource.getBarId() ?? '',
        name: localSource.getBarName() ?? '',
      ),
    );
  }

  @override
  Future<void> logout() async {
    final refreshToken = localSource.getRefreshToken();
    if (refreshToken != null) {
      await remoteDataSource.logout(refreshToken);
    }
    await localSource.clearSession();
  }

  @override
  Future<void> clearLocalSession() => localSource.clearSession();

  void _saveCashier(BarCashier cashier) {
    localSource.setCashier(
      id: cashier.id,
      fullName: cashier.fullName,
      username: cashier.username,
      barId: cashier.bar.id,
      barName: cashier.bar.name,
    );
  }
}
