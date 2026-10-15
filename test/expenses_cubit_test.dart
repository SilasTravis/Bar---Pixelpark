import 'package:bar_app/core/error/failure.dart';
import 'package:bar_app/features/expenses/domain/bar_expense.dart';
import 'package:bar_app/features/expenses/presentation/cubit/expenses_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';
import 'helpers/fixtures.dart';

void main() {
  late FakeExpensesRepository repo;
  late ExpensesCubit cubit;

  setUp(() {
    repo = FakeExpensesRepository();
    var n = 0;
    cubit = ExpensesCubit(repo, newClientExpenseId: () => 'id-${++n}');
  });

  tearDown(() => cubit.close());

  test('load: list and totals', () async {
    repo.shiftExpenses = [
      expenseFixture(
        id: 'b',
        amountUzs: 40000,
        paidFrom: ExpensePaidFrom.other,
      ),
      expenseFixture(id: 'a', amountUzs: 25000),
    ];
    await cubit.load();
    expect(cubit.state.status, ExpensesStatus.loaded);
    expect(cubit.state.expenses.map((e) => e.id), ['b', 'a']);
    expect(cubit.state.totalUzs, 65000);
    expect(cubit.state.cashUzs, 25000);
  });

  test('load failure keeps the known list', () async {
    repo.shiftExpenses = [expenseFixture()];
    await cubit.load();
    repo.fetchResults.add(Left(NoInternetFailure()));
    await cubit.load();
    expect(cubit.state.status, ExpensesStatus.failure);
    expect(cubit.state.failure, isA<NoInternetFailure>());
    expect(cubit.state.expenses, hasLength(1));
  });

  test(
    'add puts the saved expense on top; a replay is not duplicated',
    () async {
      repo.shiftExpenses = [expenseFixture(id: 'a')];
      await cubit.load();
      final saved = expenseFixture(id: 'b', name: 'Muz', amountUzs: 12000);
      repo.createResults
        ..add(Right(saved))
        ..add(Right(saved));
      final id = cubit.newClientExpenseId();
      await cubit.add(
        clientExpenseId: id,
        name: 'Muz',
        amountUzs: 12000,
        paidFrom: ExpensePaidFrom.cash,
      );
      await cubit.add(
        clientExpenseId: id,
        name: 'Muz',
        amountUzs: 12000,
        paidFrom: ExpensePaidFrom.cash,
      );
      expect(cubit.state.expenses.map((e) => e.id), ['b', 'a']);
      expect(repo.created.map((r) => r.clientExpenseId), ['id-1', 'id-1']);
    },
  );

  test('add failure leaves the list alone', () async {
    await cubit.load();
    repo.createResults.add(
      Left(ServerFailure(message: 'x', code: BarErrorCodes.shiftNotOpen)),
    );
    final result = await cubit.add(
      clientExpenseId: 'k',
      name: 'Sut',
      amountUzs: 1,
      paidFrom: ExpensePaidFrom.cash,
    );
    expect(result.isLeft(), isTrue);
    expect(cubit.state.expenses, isEmpty);
  });

  test('delete removes the row; NOT_FOUND reloads', () async {
    repo.shiftExpenses = [expenseFixture(id: 'a'), expenseFixture(id: 'b')];
    await cubit.load();
    await cubit.delete('a');
    expect(cubit.state.expenses.map((e) => e.id), ['b']);

    repo.deleteResults.add(
      Left(ServerFailure(message: 'x', code: BarErrorCodes.expenseNotFound)),
    );
    repo.shiftExpenses = const [];
    final calls = repo.fetchCalls;
    final result = await cubit.delete('b');
    await Future<void>.delayed(Duration.zero);
    expect(result.isLeft(), isTrue);
    expect(repo.fetchCalls, calls + 1);
    expect(cubit.state.expenses, isEmpty);
  });

  test('suggestions load', () async {
    repo.suggestions = const [
      ExpenseSuggestion(name: 'Sut', lastAmountUzs: 25000, count: 7),
    ];
    await cubit.loadSuggestions();
    expect(cubit.state.suggestions.single.name, 'Sut');
  });
}
