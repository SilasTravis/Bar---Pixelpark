import 'package:bar_app/core/error/failure.dart';
import 'package:bar_app/features/inventory/domain/inventory_repository.dart';
import 'package:bar_app/features/inventory/domain/stock_item.dart';
import 'package:bar_app/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';
import 'helpers/fixtures.dart';

void main() {
  late FakeInventoryRepository repo;
  late InventoryCubit cubit;

  setUp(() {
    repo = FakeInventoryRepository();
    var n = 0;
    cubit = InventoryCubit(repo, newRequestId: () => 'req-${++n}');
  });

  tearDown(() => cubit.close());

  test('load: items and total', () async {
    repo.items = [stockFixture(), stockFixture(id: 'm', name: 'Sut')];
    await cubit.load();
    expect(cubit.state.status, InventoryStatus.loaded);
    expect(cubit.state.items, hasLength(2));
    expect(cubit.state.hasMore, isFalse);
  });

  test('failure (e.g. 404 not deployed) is reported, not thrown', () async {
    repo.itemsFailure = ServerFailure(message: 'nf', statusCode: 404);
    await cubit.load();
    expect(cubit.state.status, InventoryStatus.failure);
    expect((cubit.state.failure as ServerFailure).statusCode, 404);
  });

  test('low filter and search go to the repository', () async {
    repo.items = [
      stockFixture(qtyOnHand: 5000),
      stockFixture(id: 'm', name: 'Sut', qtyOnHand: 0),
    ];
    await cubit.load(lowOnly: true);
    expect(cubit.state.items.map((i) => i.id), ['m']);
    await cubit.load(lowOnly: false, search: 'kof');
    expect(cubit.state.items.map((i) => i.id), ['s-coffee']);
    expect(repo.fetchArgs.last.search, 'kof');
  });

  test('kirim sends the request id and reloads the list', () async {
    repo.items = [stockFixture(qtyOnHand: 0)];
    await cubit.load();
    final result = await cubit.submit(
      StockBatchKind.receipt,
      requestId: cubit.newRequestId(),
      stockItemId: 's-coffee',
      qty: 2000,
      reason: 'Yetkazib berish',
    );
    expect(result.isRight(), isTrue);
    expect(repo.batches.single.requestId, 'req-1');
    expect(repo.batches.single.qty, 2000);
    expect(cubit.state.items.single.qtyOnHand, 2000);
  });

  test('a failed batch keeps the list; the retry reuses the id', () async {
    repo.items = [stockFixture()];
    await cubit.load();
    repo.batchResults.add(Left(NoInternetFailure()));
    final id = cubit.newRequestId();
    final first = await cubit.submit(
      StockBatchKind.writeoff,
      requestId: id,
      stockItemId: 's-coffee',
      qty: 100,
      reason: 'Brak',
    );
    expect(first.isLeft(), isTrue);
    expect(cubit.state.items.single.qtyOnHand, 5000);
    await cubit.submit(
      StockBatchKind.writeoff,
      requestId: id,
      stockItemId: 's-coffee',
      qty: 100,
      reason: 'Brak',
    );
    expect(repo.batches.map((b) => b.requestId), [id, id]);
    expect(cubit.state.items.single.qtyOnHand, 4900);
  });

  test('count sets the absolute quantity', () async {
    repo.items = [stockFixture()];
    await cubit.load();
    await cubit.submit(
      StockBatchKind.count,
      requestId: 'r',
      stockItemId: 's-coffee',
      qty: 0,
    );
    expect(cubit.state.items.single.status, StockStatus.out);
  });

  test('createItem reloads', () async {
    await cubit.createItem(name: 'Shakar', unit: StockUnit.g, minQty: 500);
    expect(repo.createdItems.single.name, 'Shakar');
    expect(cubit.state.items.single.name, 'Shakar');
  });

  test('fetchAllActive returns every item', () async {
    repo.items = [stockFixture(), stockFixture(id: 'm')];
    final all = await cubit.fetchAllActive();
    expect(all.getOrElse(() => const []), hasLength(2));
  });
}
