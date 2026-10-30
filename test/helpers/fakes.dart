import 'dart:async';
import 'dart:collection';

import 'package:bar_app/core/error/failure.dart';
import 'package:bar_app/features/auth/domain/entities/bar_cashier.dart';
import 'package:bar_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bar_app/features/expenses/domain/bar_expense.dart';
import 'package:bar_app/features/expenses/domain/expenses_repository.dart';
import 'package:bar_app/features/incomes/domain/bar_income.dart';
import 'package:bar_app/features/incomes/domain/incomes_repository.dart';
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
