import 'package:bar_app/core/error/failure.dart';
import 'package:bar_app/features/shift/domain/bar_shift.dart';
import 'package:bar_app/features/shift/presentation/cubit/shift_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';
import 'helpers/fixtures.dart';

BarShift shiftFixture({DateTime? closedAt, int cash = 50000}) => BarShift(
  id: 'shift-1',
  bar: bar,
  cashierId: 'c-1',
  cashierName: 'Aziz',
  openedAt: DateTime.utc(2026, 10, 6, 8),
  closedAt: closedAt,
  cashTotalUzs: cash,
  cardTotalUzs: 20000,
  totalUzs: cash + 20000,
  salesCount: 4,
  refundedCount: 1,
);

void main() {
  late FakeShiftRepository repo;
  late ShiftCubit cubit;

  setUp(() {
    repo = FakeShiftRepository();
    cubit = ShiftCubit(repo);
  });

  tearDown(() => cubit.close());

  test('no current shift → none; open → open', () async {
    repo.currentResults.add(const Right(null));
    await cubit.load();
    expect(cubit.state.status, ShiftStatus.none);

    repo.openResults.add(Right(shiftFixture()));
    await cubit.openShift();
    expect(cubit.state.status, ShiftStatus.open);
    expect(cubit.state.shift!.cashTotalUzs, 50000);
  });

  test('BAR_SHIFT_ALREADY_OPEN on open picks the existing shift up', () async {
    repo.currentResults
      ..add(const Right(null))
      ..add(Right(shiftFixture()));
    await cubit.load();
    repo.openResults.add(
      Left(
        ServerFailure(
          message: 'x',
          code: BarErrorCodes.shiftAlreadyOpen,
          statusCode: 409,
        ),
      ),
    );
    await cubit.openShift();
    expect(cubit.state.status, ShiftStatus.open);
  });

  test('a failed background refresh keeps the open shift', () async {
    repo.currentResults
      ..add(Right(shiftFixture()))
      ..add(Left(NoInternetFailure()));
    await cubit.load();
    await cubit.load();
    expect(cubit.state.status, ShiftStatus.open);
  });

  test('first load failure is reported', () async {
    repo.currentResults.add(Left(NoInternetFailure()));
    await cubit.load();
    expect(cubit.state.status, ShiftStatus.failure);
    expect(cubit.state.failure, isA<NoInternetFailure>());
  });

  test('close returns the closed shift and goes back to "no shift"', () async {
    repo.currentResults.add(Right(shiftFixture()));
    await cubit.load();
    final closed = BarShift(
      id: 'shift-1',
      bar: bar,
      cashierId: 'c-1',
      cashierName: 'Aziz',
      openedAt: DateTime.utc(2026, 10, 6, 8),
      closedAt: DateTime.utc(2026, 10, 6, 20),
      cashTotalUzs: 50000,
      countedCashUzs: 48000,
      cashDifferenceUzs: -2000,
    );
    repo.closeResults.add(Right(closed));
    final result = await cubit.closeShift(countedCashUzs: 48000);
    expect(result.isRight(), isTrue);
    expect(repo.closedWith, [48000]);
    expect(cubit.state.status, ShiftStatus.none);
  });

  test('live cash difference', () {
    expect(cashDifference(countedCashUzs: null, cashTotalUzs: 5000), isNull);
    expect(cashDifference(countedCashUzs: 5000, cashTotalUzs: 5000), 0);
    expect(cashDifference(countedCashUzs: 7000, cashTotalUzs: 5000), 2000);
    expect(cashDifference(countedCashUzs: 0, cashTotalUzs: 5000), -5000);
  });
}
