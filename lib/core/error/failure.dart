import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'exceptions.dart';

abstract class Failure extends Equatable {
  @override
  bool get stringify => true;
}

/// A rejection from the backend — `message` is already the Uzbek string
/// extracted from the API's `{en,ru,uz}` envelope.
class ServerFailure extends Failure {
  ServerFailure({required this.message, this.code, this.statusCode});

  final String message;

  /// Machine-readable error code (e.g. `BAR_SHIFT_NOT_OPEN`), when present.
  final String? code;
  final int? statusCode;

  /// 5xx: the server broke mid-request, so a write may or may not have
  /// happened — treat like a network failure (keep the cart, retry).
  bool get isServerError => (statusCode ?? 0) >= 500;

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// No answer from the server (offline, DNS, timeout).
class NoInternetFailure extends Failure {
  @override
  List<Object?> get props => [];
}

/// Backend error codes this app reacts to (see the bar design spec).
abstract final class BarErrorCodes {
  static const shiftNotOpen = 'BAR_SHIFT_NOT_OPEN';
  static const shiftAlreadyOpen = 'BAR_SHIFT_ALREADY_OPEN';
  static const productUnavailable = 'BAR_PRODUCT_UNAVAILABLE';
  static const emptyCart = 'BAR_EMPTY_CART';
  static const cashierInactive = 'BAR_CASHIER_INACTIVE';
  static const barInactive = 'BAR_INACTIVE';
  static const saleNotInShift = 'BAR_SALE_NOT_IN_SHIFT';
  static const saleAlreadyRefunded = 'BAR_SALE_ALREADY_REFUNDED';
  static const invalidPaymentSplit = 'BAR_INVALID_PAYMENT_SPLIT';
}

/// True when the account itself can no longer work (deactivated cashier or
/// bar): the app signs out instead of letting the cashier retry.
bool isAccountBlocked(Failure failure) =>
    failure is ServerFailure &&
    (failure.code == BarErrorCodes.cashierInactive ||
        failure.code == BarErrorCodes.barInactive);

/// Runs a datasource call and folds its exception contract into an
/// [Either]. A response that can't be parsed (a `TypeError` or
/// `FormatException` from a model's `fromJson`) becomes a [ServerFailure]
/// with an "unreadable response" message rather than crashing.
Future<Either<Failure, T>> guardFailures<T>(Future<T> Function() body) async {
  try {
    return Right(await body());
  } on ServerException catch (e) {
    return Left(
      ServerFailure(message: e.message, code: e.code, statusCode: e.statusCode),
    );
  } on NoInternetException {
    return Left(NoInternetFailure());
  } on FormatException {
    return Left(ServerFailure(message: "Server javobini o'qib bo'lmadi"));
  } on TypeError {
    return Left(ServerFailure(message: "Server javobini o'qib bo'lmadi"));
  }
}
