import 'package:dio/dio.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/utils/json_read.dart';
import '../domain/bar_expense.dart';

abstract class ExpensesRemoteDataSource {
  Future<List<BarExpense>> fetchShiftExpenses();
  Future<BarExpense> create({
    required String clientExpenseId,
    required String name,
    required int amountUzs,
    required ExpensePaidFrom paidFrom,
    String? note,
  });
  Future<void> delete(String expenseId);
  Future<List<ExpenseSuggestion>> fetchSuggestions();
}

class ExpensesRemoteDataSourceImpl implements ExpensesRemoteDataSource {
  ExpensesRemoteDataSourceImpl(this.dio);

  final Dio dio;

  @override
  Future<List<BarExpense>> fetchShiftExpenses() async {
    try {
      final response = await dio.get('/v1/bar/expenses');
      return readMapList(
        readMap(response.data)['items'],
      ).map(BarExpense.fromJson).toList();
    } on DioException catch (e) {
      throw exceptionFromDio(e);
    }
  }

  /// Safe to re-send (the retry interceptor may): the body carries
  /// [clientExpenseId] and the backend answers a repeated id with the expense
  /// it already recorded.
  @override
  Future<BarExpense> create({
    required String clientExpenseId,
    required String name,
    required int amountUzs,
    required ExpensePaidFrom paidFrom,
    String? note,
  }) async {
    final trimmedNote = note?.trim();
    try {
      final response = await dio.post(
        '/v1/bar/expenses',
        data: {
          'clientExpenseId': clientExpenseId,
          'name': name.trim(),
          'amountUzs': amountUzs,
          'paidFrom': paidFrom.apiValue,
          if (trimmedNote != null && trimmedNote.isNotEmpty)
            'note': trimmedNote,
        },
      );
      return BarExpense.fromJson(readMap(response.data));
    } on DioException catch (e) {
      throw exceptionFromDio(e);
    }
  }

  @override
  Future<void> delete(String expenseId) async {
    try {
      await dio.delete('/v1/bar/expenses/${Uri.encodeComponent(expenseId)}');
    } on DioException catch (e) {
      throw exceptionFromDio(e);
    }
  }

  @override
  Future<List<ExpenseSuggestion>> fetchSuggestions() async {
    try {
      final response = await dio.get('/v1/bar/expenses/suggestions');
      return readMapList(readMap(response.data)['items'])
          .map(ExpenseSuggestion.fromJson)
          .where((s) => s.name.trim().isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw exceptionFromDio(e);
    }
  }
}
