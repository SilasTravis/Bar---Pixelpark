part of 'login_bloc.dart';

class LoginState extends Equatable {
  const LoginState({this.isLoading = false, this.failure, this.cashier});

  final bool isLoading;

  /// The last failed attempt; the page maps it to a localized message.
  final Failure? failure;
  final BarCashier? cashier;

  @override
  List<Object?> get props => [isLoading, failure, cashier];
}
