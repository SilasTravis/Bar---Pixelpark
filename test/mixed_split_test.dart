import 'package:bar_app/features/sale/domain/mixed_split.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const total = 44000;

  test('starts empty, not valid, no hint', () {
    const split = MixedSplit(total);
    expect(split.cashUzs, isNull);
    expect(split.cardUzs, isNull);
    expect(split.driver, isNull);
    expect(split.isEmpty, isTrue);
    expect(split.isValid, isFalse);
    expect(split.showsInvalidHint, isFalse);
  });

  test('typing cash fills card with the rest', () {
    final split = const MixedSplit(total).editCash(30000);
    expect(split.cashUzs, 30000);
    expect(split.cardUzs, 14000);
    expect(split.driver, SplitField.cash);
    expect(split.isValid, isTrue);
    expect(split.showsInvalidHint, isFalse);
  });

  test('typing card fills cash with the rest', () {
    final split = const MixedSplit(total).editCard(4000);
    expect(split.cashUzs, 40000);
    expect(split.cardUzs, 4000);
    expect(split.driver, SplitField.card);
    expect(split.isValid, isTrue);
  });

  test('the field edited last drives', () {
    final split = const MixedSplit(
      total,
    ).editCash(30000).editCard(10000).editCash(1000);
    expect(split.cashUzs, 1000);
    expect(split.cardUzs, 43000);
    expect(split.driver, SplitField.cash);
  });

  test('more than the total clamps the other side to 0 (invalid)', () {
    final cash = const MixedSplit(total).editCash(50000);
    expect(cash.cashUzs, 50000);
    expect(cash.cardUzs, 0);
    expect(cash.isValid, isFalse);
    expect(cash.showsInvalidHint, isTrue);

    final card = const MixedSplit(total).editCard(99999999);
    expect(card.cashUzs, 0);
    expect(card.cardUzs, 99999999);
    expect(card.isValid, isFalse);
  });

  test('the whole total on one side is not a split', () {
    expect(const MixedSplit(total).editCash(total).isValid, isFalse);
    expect(const MixedSplit(total).editCard(total).isValid, isFalse);
    expect(const MixedSplit(total).editCash(0).isValid, isFalse);
    expect(const MixedSplit(total).editCard(0).isValid, isFalse);
  });

  test('clearing a field clears both', () {
    final split = const MixedSplit(total).editCash(30000).editCash(null);
    expect(split.cashUzs, isNull);
    expect(split.cardUzs, isNull);
    expect(split.isEmpty, isTrue);
    expect(split.showsInvalidHint, isFalse);
    expect(const MixedSplit(total).editCard(1).editCard(null).isEmpty, isTrue);
  });

  test('smallest splittable total is 2 (1 + 1)', () {
    expect(const MixedSplit(2).editCash(1).isValid, isTrue);
    expect(MixedSplit.minTotalUzs, 2);
  });

  test('cash suggestions are the common notes below the total', () {
    expect(cashSuggestions(44000), [10000, 20000]);
    expect(cashSuggestions(150000), [10000, 20000, 50000, 100000]);
    expect(cashSuggestions(10000), isEmpty);
    expect(cashSuggestions(10001), [10000]);
  });
}
