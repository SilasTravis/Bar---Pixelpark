import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/bar_cashier.dart';
import '../models/auth_models.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login({
    required String username,
    required String password,
  });
  Future<BarCashier> getMe();
  Future<void> logout(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this.dio);

  final Dio dio;

  @override
  Future<LoginResponseModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/v1/bar/auth/login',
        data: {'username': username, 'password': password},
      );
      return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw exceptionFromDio(e);
    }
  }

  @override
  Future<BarCashier> getMe() async {
    try {
      final response = await dio.get('/v1/bar/auth/me');
      return meResponseFromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw exceptionFromDio(e);
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await dio.post(
        '/v1/bar/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } on DioException {
      // Logout is best-effort — the local session is cleared regardless.
    }
  }
}
