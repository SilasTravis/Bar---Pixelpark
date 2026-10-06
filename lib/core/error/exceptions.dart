import 'dart:io';

import 'package:dio/dio.dart';

const String _genericMessage = "Nimadir noto'g'ri ketdi";

/// Thrown by datasources when the backend answered with a non-2xx status.
/// Mirrors the maestro backend's error envelope:
/// `{ statusCode, code, message: {en, ru, uz} | string, ... }`.
class ServerException implements Exception {
  ServerException({required this.message, this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  /// [httpStatus] is the response's real status, used when the body itself
  /// carries none (a proxy error page, an empty body).
  factory ServerException.fromJson(dynamic json, {int? httpStatus}) {
    if (json is! Map) {
      return ServerException(message: _genericMessage, statusCode: httpStatus);
    }
    final map = Map<String, dynamic>.from(json);
    final rawMessage = map['message'];
    String message;
    if (rawMessage is Map) {
      message = (rawMessage['uz'] ?? rawMessage['en'] ?? _genericMessage)
          .toString();
    } else if (rawMessage is String) {
      message = rawMessage;
    } else if (rawMessage is List && rawMessage.isNotEmpty) {
      // class-validator style: a list of messages.
      message = rawMessage.join(', ');
    } else {
      message = _genericMessage;
    }
    return ServerException(
      message: message,
      code: map['code']?.toString(),
      statusCode: map['statusCode'] is int
          ? map['statusCode'] as int
          : httpStatus,
    );
  }

  @override
  String toString() => 'ServerException($statusCode, $code): $message';
}

/// The request never got an answer: no connection, DNS failure, timeout.
/// For a sale this means "outcome unknown" — the cart and its
/// `clientSaleId` must be kept so a retry cannot double-charge.
class NoInternetException implements Exception {}

/// Converts a [DioException] into the datasource exception contract:
/// [NoInternetException] when the server never answered, otherwise a
/// [ServerException] carrying the backend's `code` and HTTP status.
Exception exceptionFromDio(DioException e) {
  final response = e.response;
  if (response == null || isConnectionError(e)) return NoInternetException();
  return ServerException.fromJson(
    response.data,
    httpStatus: response.statusCode,
  );
}

bool isConnectionError(DioException e) => switch (e.type) {
  DioExceptionType.connectionError ||
  DioExceptionType.connectionTimeout ||
  DioExceptionType.sendTimeout ||
  DioExceptionType.receiveTimeout => true,
  DioExceptionType.unknown => e.error is SocketException || e.response == null,
  _ => false,
};
