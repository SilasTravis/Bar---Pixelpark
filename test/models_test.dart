import 'dart:io';

import 'package:bar_app/core/error/exceptions.dart';
import 'package:bar_app/core/error/failure.dart';
import 'package:bar_app/features/auth/data/models/auth_models.dart';
import 'package:bar_app/features/products/domain/bar_product.dart';
import 'package:bar_app/features/sale/domain/bar_sale.dart';
import 'package:bar_app/features/shift/domain/bar_shift.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Payloads shaped exactly like the bar design spec's "API contract".
void main() {
  const barJson = {'id': 'bar-1', 'name': 'Bar Megaplanet'};
  const cashierJson = {
    'id': 'c-1',
    'fullName': 'Aziz Karimov',
    'username': 'aziz',
    'bar': barJson,
  };

  test('login response: { cashier: BarCashier, tokens }', () {
    final login = LoginResponseModel.fromJson({
      'cashier': cashierJson,
      'tokens': {
        'accessToken': 'acc',
        'refreshToken': 'ref',
        'expiresIn': 900,
        'tokenType': 'Bearer',
      },
    });
    expect(login.cashier.fullName, 'Aziz Karimov');
    expect(login.cashier.username, 'aziz');
    expect(login.cashier.bar.name, 'Bar Megaplanet');
    expect(login.tokens.accessToken, 'acc');
    expect(login.tokens.refreshToken, 'ref');
  });

  test('me response: { cashier: BarCashier }', () {
    final cashier = meResponseFromJson({'cashier': cashierJson});
    expect(cashier.id, 'c-1');
    expect(cashier.bar.id, 'bar-1');
  });

  test('BarProduct', () {
    final product = BarProduct.fromJson({
      'id': 'p-1',
      'name': 'Latte',
      'category': 'Issiq ichimliklar',
      'icon': 'ph ph-coffee',
      'priceUzs': 25000,
      'sortOrder': 3,
    });
    expect(product.priceUzs, 25000);
    expect(product.sortOrder, 3);
    expect(product.icon, 'ph ph-coffee');
  });

  group('BarProduct.imageUrl', () {
    BarProduct parse(Map<String, dynamic> extra) => BarProduct.fromJson({
      'id': 'p-1',
      'name': 'Latte',
      'category': 'Issiq',
      'icon': 'coffee',
      'priceUzs': 25000,
      'sortOrder': 0,
      ...extra,
    });

    test('absolute URL is kept', () {
      const url = 'https://cdn.pixelpark.uz/bar/latte.jpg';
      expect(parse({'imageUrl': url}).imageUrl, url);
      expect(
        parse({'imageUrl': 'http://10.0.0.5/img/1.png'}).imageUrl,
        'http://10.0.0.5/img/1.png',
      );
    });

    test('missing (older server) → null', () {
      expect(parse({}).imageUrl, isNull);
    });

    test('null → null', () {
      expect(parse({'imageUrl': null}).imageUrl, isNull);
    });

    test('blank, relative or non-http values → null', () {
      for (final bad in [
        '',
        '   ',
        '/uploads/latte.jpg',
        'latte.jpg',
        'file:///etc/passwd',
        'ftp://host/x.png',
      ]) {
        expect(parse({'imageUrl': bad}).imageUrl, isNull, reason: bad);
      }
    });

    test('surrounding whitespace is trimmed', () {
      expect(
        parse({'imageUrl': '  https://cdn.pixelpark.uz/a.png '}).imageUrl,
        'https://cdn.pixelpark.uz/a.png',
      );
    });

    test('imageUrl takes part in equality (catalog refresh rebuilds)', () {
      expect(
        parse({'imageUrl': 'https://cdn.pixelpark.uz/a.png'}),
        isNot(parse({})),
      );
    });
  });

  test('money fields leaked as strings (BIGINT) still parse', () {
    final product = BarProduct.fromJson({
      'id': 'p-1',
      'name': 'Latte',
      'category': 'Issiq',
      'icon': 'coffee',
      'priceUzs': '25000',
      'sortOrder': 0,
    });
    expect(product.priceUzs, 25000);
  });

  test('BarSale with items, completed', () {
    final sale = BarSale.fromJson({
      'id': 's-1',
      'receiptNo': 42,
      'bar': barJson,
      'shiftId': 'sh-1',
      'cashierId': 'c-1',
      'cashierName': 'Aziz Karimov',
      'paymentMethod': 'card',
      'totalUzs': 37000,
      'status': 'completed',
      'refundedAt': null,
      'refundedBy': null,
      'refundReason': null,
      'createdAt': '2026-10-06T07:15:00.000Z',
      'items': [
        {
          'productId': 'p-1',
          'name': 'Latte',
          'priceUzs': 25000,
          'quantity': 1,
          'lineTotalUzs': 25000,
        },
        {
          'productId': 'p-2',
          'name': 'Cookie',
          'priceUzs': 6000,
          'quantity': 2,
          'lineTotalUzs': 12000,
        },
      ],
    });
    expect(sale.receiptNo, 42);
    expect(sale.paymentMethod, PaymentMethod.card);
    expect(sale.status, SaleStatus.completed);
    expect(sale.isRefunded, isFalse);
    expect(sale.createdAt, DateTime.utc(2026, 10, 6, 7, 15));
    expect(sale.items, hasLength(2));
    expect(sale.items[1].quantity, 2);
    expect(sale.items[1].lineTotalUzs, 12000);
    expect(sale.refundedAt, isNull);
  });

  test('BarSale refunded by admin', () {
    final sale = BarSale.fromJson({
      'id': 's-2',
      'receiptNo': 43,
      'bar': barJson,
      'shiftId': 'sh-1',
      'cashierId': 'c-1',
      'cashierName': 'Aziz',
      'paymentMethod': 'cash',
      'totalUzs': 12000,
      'status': 'refunded',
      'refundedAt': '2026-10-06T08:00:00.000Z',
      'refundedBy': 'admin',
      'refundReason': 'Xato urildi',
      'createdAt': '2026-10-06T07:59:00.000Z',
      'items': <dynamic>[],
    });
    expect(sale.isRefunded, isTrue);
    expect(sale.paymentMethod, PaymentMethod.cash);
    expect(sale.refundedBy, 'admin');
    expect(sale.refundReason, 'Xato urildi');
    expect(sale.refundedAt, isNotNull);
  });

  test('BarShift open (nullable close fields) via shifts/current', () {
    final shift = BarShift.fromCurrentResponse({
      'shift': {
        'id': 'sh-1',
        'bar': barJson,
        'cashierId': 'c-1',
        'cashierName': 'Aziz',
        'openedAt': '2026-10-06T03:00:00.000Z',
        'closedAt': null,
        'cashTotalUzs': 120000,
        'cardTotalUzs': 80000,
        'totalUzs': 200000,
        'salesCount': 9,
        'refundedCount': 1,
        'countedCashUzs': null,
        'cashDifferenceUzs': null,
        'note': null,
      },
    })!;
    expect(shift.isOpen, isTrue);
    expect(shift.totalUzs, 200000);
    expect(shift.salesCount, 9);
    expect(shift.refundedCount, 1);
    expect(shift.countedCashUzs, isNull);
    expect(shift.cashDifferenceUzs, isNull);
  });

  test('shifts/current with { shift: null } means no open shift', () {
    expect(BarShift.fromCurrentResponse({'shift': null}), isNull);
  });

  test('BarShift closed', () {
    final shift = BarShift.fromJson({
      'id': 'sh-1',
      'bar': barJson,
      'cashierId': 'c-1',
      'cashierName': 'Aziz',
      'openedAt': '2026-10-06T03:00:00.000Z',
      'closedAt': '2026-10-06T17:00:00.000Z',
      'cashTotalUzs': 120000,
      'cardTotalUzs': 80000,
      'totalUzs': 200000,
      'salesCount': 9,
      'refundedCount': 1,
      'countedCashUzs': 118000,
      'cashDifferenceUzs': -2000,
      'note': 'Kamomad',
    });
    expect(shift.isOpen, isFalse);
    expect(shift.countedCashUzs, 118000);
    expect(shift.cashDifferenceUzs, -2000);
    expect(shift.note, 'Kamomad');
  });

  group('error mapping', () {
    final request = RequestOptions(path: '/v1/bar/sales');

    test('backend envelope → ServerException with code + status', () {
      final e = exceptionFromDio(
        DioException(
          requestOptions: request,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: request,
            statusCode: 422,
            data: {
              'statusCode': 422,
              'code': 'BAR_PRODUCT_UNAVAILABLE',
              'message': {'uz': 'Mahsulot mavjud emas', 'en': 'Unavailable'},
            },
          ),
        ),
      );
      expect(e, isA<ServerException>());
      final server = e as ServerException;
      expect(server.code, 'BAR_PRODUCT_UNAVAILABLE');
      expect(server.statusCode, 422);
      expect(server.message, 'Mahsulot mavjud emas');
    });

    test('a 502 HTML page keeps the HTTP status', () {
      final e =
          exceptionFromDio(
                DioException(
                  requestOptions: request,
                  type: DioExceptionType.badResponse,
                  response: Response(
                    requestOptions: request,
                    statusCode: 502,
                    data: '<html>Bad gateway</html>',
                  ),
                ),
              )
              as ServerException;
      expect(e.statusCode, 502);
      expect(e.code, isNull);
    });

    test('no response (offline, timeout) → NoInternetException', () {
      for (final type in [
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(
          exceptionFromDio(DioException(requestOptions: request, type: type)),
          isA<NoInternetException>(),
        );
      }
      expect(
        exceptionFromDio(
          DioException(
            requestOptions: request,
            error: const SocketException('down'),
          ),
        ),
        isA<NoInternetException>(),
      );
    });

    test('guardFailures folds exceptions into failures', () async {
      expect(
        await guardFailures<int>(() async => throw NoInternetException()),
        Left<Failure, int>(NoInternetFailure()),
      );
      final server = await guardFailures<int>(
        () async => throw ServerException(
          message: 'm',
          code: 'BAR_SHIFT_NOT_OPEN',
          statusCode: 409,
        ),
      );
      expect(
        server,
        Left<Failure, int>(
          ServerFailure(
            message: 'm',
            code: 'BAR_SHIFT_NOT_OPEN',
            statusCode: 409,
          ),
        ),
      );
      final parse = await guardFailures<int>(
        () async => throw const FormatException('bad'),
      );
      expect(parse.isLeft(), isTrue);
      expect(await guardFailures(() async => 5), const Right<Failure, int>(5));
    });

    test('5xx is flagged as a server error; account blocks are detected', () {
      expect(ServerFailure(message: '', statusCode: 503).isServerError, isTrue);
      expect(
        ServerFailure(message: '', statusCode: 409).isServerError,
        isFalse,
      );
      expect(
        isAccountBlocked(
          ServerFailure(message: '', code: BarErrorCodes.barInactive),
        ),
        isTrue,
      );
      expect(isAccountBlocked(NoInternetFailure()), isFalse);
    });
  });
}
