import '../../domain/entities/bar_cashier.dart';

/// Same shape as the POS cashier tokens: `{ accessToken, refreshToken, ... }`.
/// Only the two tokens are needed here; extra fields are ignored.
class AuthTokensModel {
  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) =>
      AuthTokensModel(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );
}

/// `POST /v1/bar/auth/login` → `{ cashier: BarCashier, tokens }`.
class LoginResponseModel {
  const LoginResponseModel({required this.cashier, required this.tokens});

  final BarCashier cashier;
  final AuthTokensModel tokens;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        cashier: BarCashier.fromJson(json['cashier'] as Map<String, dynamic>),
        tokens: AuthTokensModel.fromJson(
          json['tokens'] as Map<String, dynamic>,
        ),
      );
}

/// `GET /v1/bar/auth/me` → `{ cashier: BarCashier }`.
BarCashier meResponseFromJson(Map<String, dynamic> json) =>
    BarCashier.fromJson(json['cashier'] as Map<String, dynamic>);
