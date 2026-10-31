import 'package:bar_app/core/error/failure.dart';
import 'package:bar_app/features/incomes/domain/bar_income.dart';
import 'package:bar_app/features/incomes/presentation/cubit/incomes_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';
import 'helpers/fixtures.dart';

void main() {
  late FakeIncomesRepository repo;
  late IncomesCubit cubit;

  setUp(() {
    repo = FakeIncomesRepository();
    var n = 0;
    cubit = IncomesCubit(repo, newClientIncomeId: () => 'id-${++n}');
  });

  tearDown(() => cubit.close());

  test('load: list and totals', () async {
    repo.shiftIncomes = [
      incomeFixture(
        id: 'b',
        amountUzs: 40000,
        receivedTo: IncomeReceivedTo.other,
      ),
      incomeFixture(id: 'a', amountUzs: 25000),
    ];
    await cubit.load();
    expect(cubit.state.status, IncomesStatus.loaded);
    expect(cubit.state.incomes.map((e) => e.id), ['b', 'a']);
    expect(cubit.state.totalUzs, 65000);
    expect(cubit.state.cashUzs, 25000);
  });

  test('load failure keeps the known list', () async {
    repo.shiftIncomes = [incomeFixture()];
    await cubit.load();
    repo.fetchResults.add(Left(NoInternetFailure()));
    await cubit.load();
    expect(cubit.state.status, IncomesStatus.failure);
    expect(cubit.state.failure, isA<NoInternetFailure>());
    expect(cubit.state.incomes, hasLength(1));
  });

  test(
    'add puts the saved income on top; a replay is not duplicated',
    () async {
      repo.shiftIncomes = [incomeFixture(id: 'a')];
      await cubit.load();
      final saved = incomeFixture(id: 'b', name: 'Muz', amountUzs: 12000);
      repo.createResults
        ..add(Right(saved))
        ..add(Right(saved));
      final id = cubit.newClientIncomeId();
      await cubit.add(
        clientIncomeId: id,
        name: 'Muz',
        amountUzs: 12000,
        receivedTo: IncomeReceivedTo.cash,
      );
      await cubit.add(
        clientIncomeId: id,
        name: 'Muz',
        amountUzs: 12000,
        receivedTo: IncomeReceivedTo.cash,
      );
      expect(cubit.state.incomes.map((e) => e.id), ['b', 'a']);
      expect(repo.created.map((r) => r.clientIncomeId), ['id-1', 'id-1']);
    },
  );

  test('add failure leaves the list alone', () async {
    await cubit.load();
    repo.createResults.add(
      Left(ServerFailure(message: 'x', code: BarErrorCodes.shiftNotOpen)),
    );
    final result = await cubit.add(
      clientIncomeId: 'k',
      name: 'Sut',
      amountUzs: 1,
      receivedTo: IncomeReceivedTo.cash,
    );
    expect(result.isLeft(), isTrue);
    expect(cubit.state.incomes, isEmpty);
  });

  test('delete removes the row; NOT_FOUND reloads', () async {
    repo.shiftIncomes = [incomeFixture(id: 'a'), incomeFixture(id: 'b')];
    await cubit.load();
    await cubit.delete('a');
    expect(cubit.state.incomes.map((e) => e.id), ['b']);

    repo.deleteResults.add(
      Left(ServerFailure(message: 'x', code: BarErrorCodes.incomeNotFound)),
    );
    repo.shiftIncomes = const [];
    final calls = repo.fetchCalls;
    final result = await cubit.delete('b');
    await Future<void>.delayed(Duration.zero);
    expect(result.isLeft(), isTrue);
    expect(repo.fetchCalls, calls + 1);
    expect(cubit.state.incomes, isEmpty);
  });

  test('suggestions load', () async {
    repo.suggestions = const [
      IncomeSuggestion(name: 'Sut', lastAmountUzs: 25000, count: 7),
    ];
    await cubit.loadSuggestions();
    expect(cubit.state.suggestions.single.name, 'Sut');
  });
}
