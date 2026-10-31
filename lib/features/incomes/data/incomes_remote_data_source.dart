import 'package:dio/dio.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/utils/json_read.dart';
import '../domain/bar_income.dart';

abstract class IncomesRemoteDataSource {
  Future<List<BarIncome>> fetchShiftIncomes();
  Future<BarIncome> create({
    required String clientIncomeId,
    required String name,
    required int amountUzs,
    required IncomeReceivedTo receivedTo,
    String? note,
  });
  Future<void> delete(String incomeId);
  Future<List<IncomeSuggestion>> fetchSuggestions();
}

class IncomesRemoteDataSourceImpl implements IncomesRemoteDataSource {
  IncomesRemoteDataSourceImpl(this.dio);

  final Dio dio;

  @override
  Future<List<BarIncome>> fetchShiftIncomes() async {
    try {
      final response = await dio.get('/v1/bar/incomes');
      return readMapList(
        readMap(response.data)['items'],
      ).map(BarIncome.fromJson).toList();
    } on DioException catch (e) {
      throw exceptionFromDio(e);
    }
  }

  /// Safe to re-send (the retry interceptor may): the body carries
  /// [clientIncomeId] and the backend answers a repeated id with the income
  /// it already recorded.
  @override
  Future<BarIncome> create({
    required String clientIncomeId,
    required String name,
    required int amountUzs,
    required IncomeReceivedTo receivedTo,
    String? note,
  }) async {
    final trimmedNote = note?.trim();
    try {
      final response = await dio.post(
        '/v1/bar/incomes',
        data: {
          'clientIncomeId': clientIncomeId,
          'name': name.trim(),
          'amountUzs': amountUzs,
          'receivedTo': receivedTo.apiValue,
          if (trimmedNote != null && trimmedNote.isNotEmpty)
            'note': trimmedNote,
        },
      );
      return BarIncome.fromJson(readMap(response.data));
    } on DioException catch (e) {
      throw exceptionFromDio(e);
    }
  }

  @override
  Future<void> delete(String incomeId) async {
    try {
      await dio.delete('/v1/bar/incomes/${Uri.encodeComponent(incomeId)}');
    } on DioException catch (e) {
      throw exceptionFromDio(e);
    }
  }

  @override
  Future<List<IncomeSuggestion>> fetchSuggestions() async {
    try {
      final response = await dio.get('/v1/bar/incomes/suggestions');
      return readMapList(readMap(response.data)['items'])
          .map(IncomeSuggestion.fromJson)
          .where((s) => s.name.trim().isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw exceptionFromDio(e);
    }
  }
}
