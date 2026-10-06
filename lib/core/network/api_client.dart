import 'package:dio/dio.dart';
import 'package:dio_retry_plus/dio_retry_plus.dart';
import 'package:flutter/foundation.dart';

import '../../constants/app_constants.dart';
import '../local_source/local_source.dart';
import 'auth_interceptor.dart';
import 'token_refresher.dart';

/// Builds the shared [Dio] client: base URL from the `API_BASE_URL`
/// dart-define ([AppConstants.defaultApiBaseUrl]), auth header injection,
/// and 401-triggered token refresh + retry.
///
/// The retry interceptor may re-send `POST /v1/bar/sales` after a dropped
/// connection. That is safe by design: the body carries the cart's
/// `clientSaleId`, and the backend answers a repeated id with the sale it
/// already recorded instead of creating a second one.
Dio buildDio(LocalSource localSource, TokenRefresher tokenRefresher) {
  final dio =
      Dio(
          BaseOptions(
            baseUrl: AppConstants.defaultApiBaseUrl,
            contentType: 'application/json',
            sendTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            connectTimeout: const Duration(seconds: 10),
          ),
        )
        ..interceptors.addAll([
          AuthInterceptor(localSource),
          LogInterceptor(
            request: kDebugMode,
            responseBody: kDebugMode,
            error: kDebugMode,
            requestBody: kDebugMode,
          ),
        ]);

  dio.interceptors.add(
    RetryInterceptor(
      dio: dio,
      retryDelays: const [Duration(seconds: 3), Duration(seconds: 2)],
      toNoInternetPageNavigator: () async {},
      refreshTokenFunction: () => tokenRefresher.refresh(),
      accessTokenGetter: () {
        final accessToken = localSource.getAccessToken();
        return accessToken == null ? '' : 'Bearer $accessToken';
      },
      forbiddenFunction: () async {},
      logPrint: (message) {
        if (kDebugMode &&
            message.contains(
              RegExp('retry|error|fail', caseSensitive: false),
            )) {
          debugPrint(message);
        }
      },
    ),
  );

  return dio;
}
