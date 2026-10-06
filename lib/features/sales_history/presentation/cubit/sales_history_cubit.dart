import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../sale/domain/bar_sale.dart';
import '../../../sale/domain/sales_repository.dart';

enum HistoryStatus { loading, loaded, failure }

class SalesHistoryState extends Equatable {
  const SalesHistoryState({
    this.status = HistoryStatus.loading,
    this.sales = const [],
    this.failure,
  });

  final HistoryStatus status;

  /// The open shift's sales, newest first (server order).
  final List<BarSale> sales;
  final Failure? failure;

  int get completedCount => sales.where((s) => !s.isRefunded).length;

  @override
  List<Object?> get props => [status, sales, failure];
}

/// "Smena tarixi": the current shift's sales and the cashier's refund.
class SalesHistoryCubit extends Cubit<SalesHistoryState> {
  SalesHistoryCubit(this._repository) : super(const SalesHistoryState());

  final SalesRepository _repository;

  Future<void> load() async {
    _emit(SalesHistoryState(sales: state.sales));
    final result = await _repository.fetchShiftSales();
    result.fold(
      (failure) => _emit(
        SalesHistoryState(
          status: HistoryStatus.failure,
          sales: state.sales,
          failure: failure,
        ),
      ),
      (sales) =>
          _emit(SalesHistoryState(status: HistoryStatus.loaded, sales: sales)),
    );
  }

  /// `POST /v1/bar/sales/:id/refund`. On success the refunded sale replaces
  /// its row. `BAR_SALE_ALREADY_REFUNDED` means the list is stale, so it is
  /// reloaded either way.
  Future<Either<Failure, BarSale>> refund(
    String saleId, {
    String? reason,
  }) async {
    final result = await _repository.refund(saleId, reason: reason);
    result.fold(
      (failure) {
        if (failure is ServerFailure &&
            failure.code == BarErrorCodes.saleAlreadyRefunded) {
          load();
        }
      },
      (refunded) => _emit(
        SalesHistoryState(
          status: HistoryStatus.loaded,
          sales: [
            for (final sale in state.sales)
              sale.id == refunded.id ? refunded : sale,
          ],
        ),
      ),
    );
    return result;
  }

  void _emit(SalesHistoryState next) {
    if (!isClosed) emit(next);
  }
}
