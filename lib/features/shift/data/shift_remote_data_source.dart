import 'package:dio/dio.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/utils/json_read.dart';
import '../domain/bar_shift.dart';

abstract class ShiftRemoteDataSource {
  Future<BarShift?> fetchCurrent();
  Future<BarShift> open();
  Future<BarShift> close({required int countedCashUzs, String? note});
}

class ShiftRemoteDataSourceImpl implements ShiftRemoteDataSource {
  ShiftRemoteDataSourceImpl(this.dio);

  final Dio dio;

  @override
  Future<BarShift?> fetchCurrent() async {
    try {
      final response = await dio.get('/v1/bar/shifts/current');
      return BarShift.fromCurrentResponse(readMap(response.data));
    } on DioException catch (e) {
      throw exceptionFromDio(e);
    }
  }

  @override
  Future<BarShift> open() async {
    try {
      final response = await dio.post('/v1/bar/shifts/open');
      return BarShift.fromJson(readMap(response.data));
    } on DioException catch (e) {
      throw exceptionFromDio(e);
    }
  }

  @override
  Future<BarShift> close({required int countedCashUzs, String? note}) async {
    try {
      final response = await dio.post(
        '/v1/bar/shifts/close',
        data: {
          'countedCashUzs': countedCashUzs,
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        },
      );
      return BarShift.fromJson(readMap(response.data));
    } on DioException catch (e) {
      throw exceptionFromDio(e);
    }
  }
}
