import 'package:equatable/equatable.dart';

/// Which field of the split dialog the cashier typed in last — that one
/// drives, the other is derived from it.
enum SplitField { cash, card }

/// The state of the "Aralash" (cash + card) split dialog — pure and
/// immutable, every edit returns a new split.
///
/// Typing in one field sets the other to `total − value`, clamped to
/// `0..total`. An emptied field empties the other one too: "nothing typed"
/// is never a valid split.
class MixedSplit extends Equatable {
  const MixedSplit._(this.totalUzs, this.cashUzs, this.cardUzs, this.driver);

  /// Nothing typed yet.
  const MixedSplit(this.totalUzs)
    : cashUzs = null,
      cardUzs = null,
      driver = null;

  /// The smallest total a split makes sense for: 1 so'm on each side.
  static const int minTotalUzs = 2;

  final int totalUzs;

  /// null = the field is empty.
  final int? cashUzs;
  final int? cardUzs;

  /// The field the cashier edited last; null before the first edit.
  final SplitField? driver;

  MixedSplit editCash(int? value) => value == null
      ? MixedSplit._(totalUzs, null, null, SplitField.cash)
      : MixedSplit._(totalUzs, value, _rest(value), SplitField.cash);

  MixedSplit editCard(int? value) => value == null
      ? MixedSplit._(totalUzs, null, null, SplitField.card)
      : MixedSplit._(totalUzs, _rest(value), value, SplitField.card);

  int _rest(int value) => (totalUzs - value).clamp(0, totalUzs);

  bool get isEmpty => cashUzs == null && cardUzs == null;

  /// Both parts positive and adding up to the total exactly.
  bool get isValid {
    final cash = cashUzs;
    final card = cardUzs;
    return cash != null &&
        card != null &&
        cash > 0 &&
        card > 0 &&
        cash + card == totalUzs;
  }

  /// Show the "must add up to the total" hint: something was typed and it
  /// is not a valid split.
  bool get showsInvalidHint => !isEmpty && !isValid;

  @override
  List<Object?> get props => [totalUzs, cashUzs, cardUzs, driver];
}

/// Quick-fill cash amounts for the split dialog: the common notes a
/// customer hands over that still leave something for the card.
List<int> cashSuggestions(int totalUzs) => [
  for (final amount in const [10000, 20000, 50000, 100000])
    if (amount < totalUzs) amount,
];
