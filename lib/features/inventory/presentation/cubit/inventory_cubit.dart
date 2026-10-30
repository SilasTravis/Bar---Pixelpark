import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failure.dart';
import '../../domain/inventory_repository.dart';
import '../../domain/stock_item.dart';

enum InventoryStatus { loading, loaded, failure }

class InventoryState extends Equatable {
  const InventoryState({
    this.status = InventoryStatus.loading,
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.search = '',
    this.lowOnly = false,
    this.failure,
  });

  final InventoryStatus status;
  final List<StockItem> items;
  final int total;
  final int page;
  final String search;
  final bool lowOnly;
  final Failure? failure;

  bool get hasMore => items.length < total;

  InventoryState copyWith({
    InventoryStatus? status,
    List<StockItem>? items,
    int? total,
    int? page,
    String? search,
    bool? lowOnly,
    Failure? failure,
  }) => InventoryState(
    status: status ?? this.status,
    items: items ?? this.items,
    total: total ?? this.total,
    page: page ?? this.page,
    search: search ?? this.search,
    lowOnly: lowOnly ?? this.lowOnly,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    status,
    items,
    total,
    page,
    search,
    lowOnly,
    failure,
  ];
}

/// "Ombor": the bar's own stock. Inventory is optional for the till: this
/// cubit is only ever created by the Ombor page, so a missing / failing
/// inventory API cannot affect selling.
class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit(this._repository, {String Function()? newRequestId})
    : _newRequestId = newRequestId ?? _uuidV4,
      super(const InventoryState());

  final InventoryRepository _repository;
  final String Function() _newRequestId;

  static const pageSize = 50;
  static String _uuidV4() => const Uuid().v4();

  /// An idempotency key; a dialog takes one on open and keeps it across
  /// retries so a re-sent save cannot be applied twice.
  String newRequestId() => _newRequestId();

  int _generation = 0;

  Future<void> load({String? search, bool? lowOnly}) async {
    final nextSearch = search ?? state.search;
    final nextLow = lowOnly ?? state.lowOnly;
    final gen = ++_generation;
    _emit(
      state.copyWith(
        status: InventoryStatus.loading,
        search: nextSearch,
        lowOnly: nextLow,
      ),
    );
    final result = await _repository.fetchItems(
      search: nextSearch,
      lowOnly: nextLow,
      limit: pageSize,
    );
    if (gen != _generation) return; // a newer search superseded this one
    result.fold(
      (failure) => _emit(
        state.copyWith(status: InventoryStatus.failure, failure: failure),
      ),
      (page) => _emit(
        state.copyWith(
          status: InventoryStatus.loaded,
          items: page.items,
          total: page.total,
          page: 1,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == InventoryStatus.loading) return;
    final gen = _generation;
    final result = await _repository.fetchItems(
      search: state.search,
      lowOnly: state.lowOnly,
      page: state.page + 1,
      limit: pageSize,
    );
    if (gen != _generation) return;
    result.fold(
      (failure) => _emit(state.copyWith(failure: failure)),
      (page) => _emit(
        state.copyWith(
          items: [...state.items, ...page.items],
          total: page.total,
          page: state.page + 1,
        ),
      ),
    );
  }

  Future<Either<Failure, StockItem>> createItem({
    required String name,
    required StockUnit unit,
    required int minQty,
  }) async {
    final result = await _repository.createItem(
      name: name,
      unit: unit,
      minQty: minQty,
    );
    if (result.isRight()) await load();
    return result;
  }

  Future<Either<Failure, StockItem>> updateItem(
    String id, {
    String? name,
    int? minQty,
    bool? active,
  }) async {
    final result = await _repository.updateItem(
      id,
      name: name,
      minQty: minQty,
      active: active,
    );
    if (result.isRight()) await load();
    return result;
  }

  /// Kirim / brak / sanash for one item; reloads the list on success.
  Future<Either<Failure, Unit>> submit(
    StockBatchKind kind, {
    required String requestId,
    required String stockItemId,
    required int qty,
    String? reason,
  }) async {
    final result = await _repository.submitBatch(
      kind,
      requestId: requestId,
      stockItemId: stockItemId,
      qty: qty,
      reason: reason,
    );
    if (result.isRight()) await load();
    return result;
  }

  Future<Either<Failure, MovementsPage>> movements(String stockItemId) =>
      _repository.fetchMovements(stockItemId: stockItemId, limit: 20);

  Future<Either<Failure, ProductSetup>> fetchSetup(String productId) =>
      _repository.fetchSetup(productId);

  Future<Either<Failure, ProductSetup>> saveSetup(ProductSetup setup) =>
      _repository.saveSetup(setup);

  /// All active items (for the recipe ingredient picker), paging through.
  Future<Either<Failure, List<StockItem>>> fetchAllActive() async {
    final all = <StockItem>[];
    for (var page = 1; page <= 20; page++) {
      final result = await _repository.fetchItems(
        active: true,
        page: page,
        limit: 100,
      );
      final failure = result.fold<Failure?>((f) => f, (_) => null);
      if (failure != null) return Left(failure);
      final data = result.getOrElse(
        () => const StockPage(items: [], total: 0, page: 1),
      );
      all.addAll(data.items);
      if (all.length >= data.total || data.items.isEmpty) break;
    }
    return Right(all);
  }

  void _emit(InventoryState next) {
    if (!isClosed) emit(next);
  }
}
