import 'dart:async';
import 'dart:collection';

import 'package:bar_app/core/error/failure.dart';
import 'package:bar_app/features/auth/domain/entities/bar_cashier.dart';
import 'package:bar_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bar_app/features/expenses/domain/bar_expense.dart';
import 'package:bar_app/features/expenses/domain/expenses_repository.dart';
import 'package:bar_app/features/incomes/domain/bar_income.dart';
import 'package:bar_app/features/incomes/domain/incomes_repository.dart';
import 'package:bar_app/features/inventory/domain/inventory_repository.dart';
import 'package:bar_app/features/inventory/domain/stock_item.dart';
import 'package:bar_app/features/products/domain/bar_product.dart';
import 'package:bar_app/features/products/domain/products_repository.dart';
import 'package:bar_app/features/sale/domain/bar_sale.dart';
import 'package:bar_app/features/sale/domain/cart.dart';
import 'package:bar_app/features/sale/domain/sales_repository.dart';
import 'package:bar_app/features/shift/domain/bar_shift.dart';
import 'package:bar_app/features/shift/domain/shift_repository.dart';
import 'package:dartz/dartz.dart';

class FakeProductsRepository implements ProductsRepository {
  FakeProductsRepository(this.products);

  List<BarProduct> products;
  Failure? failure;
  int calls = 0;

  @override
  Future<Either<Failure, List<BarProduct>>> fetchProducts() async {
    calls++;
    final f = failure;
    return f != null ? Left(f) : Right(products);
  }
}

/// One recorded `POST /v1/bar/sales`.
class SaleRequest {
  SaleRequest(this.clientSaleId, this.payment, this.items);

  final String clientSaleId;
  final SalePayment payment;
  final List<Map<String, dynamic>> items;

  PaymentMethod get method => payment.method;
}

class FakeSalesRepository implements SalesRepository {
  /// Queued answers for createSale, consumed in order.
  final Queue<Either<Failure, BarSale>> createResults = Queue();
  final List<SaleRequest> requests = [];

  /// When set, createSale waits for it (to observe the in-flight state).
  Completer<void>? gate;

  @override
  Future<Either<Failure, BarSale>> createSale({
    required Cart cart,
    required SalePayment payment,
  }) async {
    requests.add(
      SaleRequest(cart.clientSaleId!, payment, cart.toRequestItems()),
    );
    if (gate != null) await gate!.future;
    return createResults.removeFirst();
  }

  /// What `GET /v1/bar/sales` answers.
  List<BarSale> shiftSales = const [];

  @override
  Future<Either<Failure, List<BarSale>>> fetchShiftSales() async =>
      Right(shiftSales);

  @override
  Future<Either<Failure, BarSale>> refund(String saleId, {String? reason}) =>
      throw UnimplementedError();
}

class FakeShiftRepository implements ShiftRepository {
  final Queue<Either<Failure, BarShift?>> currentResults = Queue();
  final Queue<Either<Failure, BarShift>> openResults = Queue();
  final Queue<Either<Failure, BarShift>> closeResults = Queue();
  final List<int> closedWith = [];

  @override
  Future<Either<Failure, BarShift?>> fetchCurrent() async =>
      currentResults.removeFirst();

  @override
  Future<Either<Failure, BarShift>> open() async => openResults.removeFirst();

  @override
  Future<Either<Failure, BarShift>> close({
    required int countedCashUzs,
    String? note,
  }) async {
    closedWith.add(countedCashUzs);
    return closeResults.removeFirst();
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this.cashier);

  final BarCashier? cashier;
  bool loggedOut = false;

  @override
  BarCashier? cachedCashier() => cashier;

  @override
  Future<Either<Failure, BarCashier>> getCurrentCashier() async =>
      Right(cashier!);

  @override
  Future<Either<Failure, BarCashier>> login({
    required String username,
    required String password,
  }) async => Right(cashier!);

  @override
  Future<void> logout() async => loggedOut = true;

  @override
  Future<void> clearLocalSession() async => loggedOut = true;
}

/// One recorded `POST /v1/bar/expenses`.
class ExpenseRequest {
  ExpenseRequest(
    this.clientExpenseId,
    this.name,
    this.amountUzs,
    this.paidFrom,
    this.note,
  );

  final String clientExpenseId;
  final String name;
  final int amountUzs;
  final ExpensePaidFrom paidFrom;
  final String? note;
}

class FakeExpensesRepository implements ExpensesRepository {
  /// What `GET /v1/bar/expenses` answers (each call consumes one when
  /// queued, else [shiftExpenses]).
  final Queue<Either<Failure, List<BarExpense>>> fetchResults = Queue();
  List<BarExpense> shiftExpenses = const [];
  int fetchCalls = 0;

  List<ExpenseSuggestion> suggestions = const [];

  final Queue<Either<Failure, BarExpense>> createResults = Queue();
  final List<ExpenseRequest> created = [];

  final Queue<Either<Failure, Unit>> deleteResults = Queue();
  final List<String> deleted = [];

  @override
  Future<Either<Failure, List<BarExpense>>> fetchShiftExpenses() async {
    fetchCalls++;
    return fetchResults.isNotEmpty
        ? fetchResults.removeFirst()
        : Right(shiftExpenses);
  }

  @override
  Future<Either<Failure, BarExpense>> create({
    required String clientExpenseId,
    required String name,
    required int amountUzs,
    required ExpensePaidFrom paidFrom,
    String? note,
  }) async {
    created.add(
      ExpenseRequest(clientExpenseId, name, amountUzs, paidFrom, note),
    );
    return createResults.removeFirst();
  }

  @override
  Future<Either<Failure, Unit>> delete(String expenseId) async {
    deleted.add(expenseId);
    return deleteResults.isNotEmpty ? deleteResults.removeFirst() : right(unit);
  }

  @override
  Future<Either<Failure, List<ExpenseSuggestion>>> fetchSuggestions() async =>
      Right(suggestions);
}

/// One recorded `POST /v1/bar/incomes`.
class IncomeRequest {
  IncomeRequest(
    this.clientIncomeId,
    this.name,
    this.amountUzs,
    this.receivedTo,
    this.note,
  );

  final String clientIncomeId;
  final String name;
  final int amountUzs;
  final IncomeReceivedTo receivedTo;
  final String? note;
}

class FakeIncomesRepository implements IncomesRepository {
  /// What `GET /v1/bar/incomes` answers (each call consumes one when
  /// queued, else [shiftIncomes]).
  final Queue<Either<Failure, List<BarIncome>>> fetchResults = Queue();
  List<BarIncome> shiftIncomes = const [];
  int fetchCalls = 0;

  List<IncomeSuggestion> suggestions = const [];

  final Queue<Either<Failure, BarIncome>> createResults = Queue();
  final List<IncomeRequest> created = [];

  final Queue<Either<Failure, Unit>> deleteResults = Queue();
  final List<String> deleted = [];

  @override
  Future<Either<Failure, List<BarIncome>>> fetchShiftIncomes() async {
    fetchCalls++;
    return fetchResults.isNotEmpty
        ? fetchResults.removeFirst()
        : Right(shiftIncomes);
  }

  @override
  Future<Either<Failure, BarIncome>> create({
    required String clientIncomeId,
    required String name,
    required int amountUzs,
    required IncomeReceivedTo receivedTo,
    String? note,
  }) async {
    created.add(
      IncomeRequest(clientIncomeId, name, amountUzs, receivedTo, note),
    );
    return createResults.removeFirst();
  }

  @override
  Future<Either<Failure, Unit>> delete(String incomeId) async {
    deleted.add(incomeId);
    return deleteResults.isNotEmpty ? deleteResults.removeFirst() : right(unit);
  }

  @override
  Future<Either<Failure, List<IncomeSuggestion>>> fetchSuggestions() async =>
      Right(suggestions);
}

/// One recorded kirim / brak / sanash.
class BatchRequest {
  BatchRequest(
    this.kind,
    this.requestId,
    this.stockItemId,
    this.qty,
    this.reason,
  );

  final StockBatchKind kind;
  final String requestId;
  final String stockItemId;
  final int qty;
  final String? reason;
}

class FakeInventoryRepository implements InventoryRepository {
  List<StockItem> items = const [];
  Failure? itemsFailure;
  int fetchCalls = 0;
  final List<({String search, bool lowOnly})> fetchArgs = [];

  final Queue<Either<Failure, Unit>> batchResults = Queue();
  final List<BatchRequest> batches = [];

  final List<({String name, StockUnit unit, int minQty})> createdItems = [];
  final List<Map<String, Object?>> updates = [];

  List<StockMovement> movements = const [];

  ProductSetup? setup;
  Failure? setupFailure;
  final List<ProductSetup> savedSetups = [];

  @override
  Future<Either<Failure, StockPage>> fetchItems({
    String search = '',
    bool lowOnly = false,
    bool? active,
    int page = 1,
    int limit = 50,
  }) async {
    fetchCalls++;
    fetchArgs.add((search: search, lowOnly: lowOnly));
    final f = itemsFailure;
    if (f != null) return Left(f);
    var list = items;
    if (lowOnly) {
      list = list.where((i) => i.status != StockStatus.ok).toList();
    }
    if (search.isNotEmpty) {
      list = list
          .where((i) => i.name.toLowerCase().contains(search.toLowerCase()))
          .toList();
    }
    return Right(StockPage(items: list, total: list.length, page: page));
  }

  @override
  Future<Either<Failure, StockItem>> createItem({
    required String name,
    required StockUnit unit,
    required int minQty,
  }) async {
    createdItems.add((name: name, unit: unit, minQty: minQty));
    final item = StockItem(
      id: 'new-${createdItems.length}',
      name: name,
      unit: unit,
      qtyOnHand: 0,
      minQty: minQty,
    );
    items = [...items, item];
    return Right(item);
  }

  @override
  Future<Either<Failure, StockItem>> updateItem(
    String id, {
    String? name,
    int? minQty,
    bool? active,
  }) async {
    updates.add({'id': id, 'name': name, 'minQty': minQty, 'active': active});
    return Right(items.firstWhere((i) => i.id == id));
  }

  @override
  Future<Either<Failure, Unit>> submitBatch(
    StockBatchKind kind, {
    required String requestId,
    required String stockItemId,
    required int qty,
    String? reason,
  }) async {
    batches.add(BatchRequest(kind, requestId, stockItemId, qty, reason));
    final result = batchResults.isNotEmpty
        ? batchResults.removeFirst()
        : right<Failure, Unit>(unit);
    if (result.isRight()) {
      items = [
        for (final i in items)
          if (i.id == stockItemId)
            StockItem(
              id: i.id,
              name: i.name,
              unit: i.unit,
              minQty: i.minQty,
              active: i.active,
              qtyOnHand: switch (kind) {
                StockBatchKind.receipt => i.qtyOnHand + qty,
                StockBatchKind.writeoff => i.qtyOnHand - qty,
                StockBatchKind.count => qty,
              },
            )
          else
            i,
      ];
    }
    return result;
  }

  @override
  Future<Either<Failure, MovementsPage>> fetchMovements({
    String? stockItemId,
    int page = 1,
    int limit = 20,
  }) async => Right(MovementsPage(items: movements, total: movements.length));

  @override
  Future<Either<Failure, ProductSetup>> fetchSetup(String productId) async {
    final f = setupFailure;
    if (f != null) return Left(f);
    return Right(
      setup ?? ProductSetup(productId: productId, kind: ProductKind.prepared),
    );
  }

  @override
  Future<Either<Failure, ProductSetup>> saveSetup(ProductSetup s) async {
    savedSetups.add(s);
    return Right(s);
  }
}
