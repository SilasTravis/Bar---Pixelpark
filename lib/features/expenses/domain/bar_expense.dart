import 'package:equatable/equatable.dart';

import '../../../core/utils/json_read.dart';

/// Where the money of an expense came from. [cash] was taken from the bar's
/// drawer, so it lowers the cash the cashier hands over at shift close;
/// [other] was paid outside the drawer (owner, card, transfer).
enum ExpensePaidFrom {
  cash('cash'),
  other('other');

  const ExpensePaidFrom(this.apiValue);

  final String apiValue;

  static ExpensePaidFrom fromApi(Object? value) =>
      value == 'other' ? ExpensePaidFrom.other : ExpensePaidFrom.cash;
}

/// The amount limits of `POST /v1/bar/expenses` (`amountUzs` 1..1 000 000 000).
abstract final class ExpenseLimits {
  static const int maxAmountUzs = 1000000000;
  static const int maxNameLength = 150;
  static const int maxNoteLength = 300;
}

/// `BarExpense` from the bar API ("chiqim": e.g. "Sut" 25 000 so'm).
class BarExpense extends Equatable {
  const BarExpense({
    required this.id,
    required this.name,
    required this.amountUzs,
    required this.paidFrom,
    required this.spentAt,
    required this.createdAt,
    this.shiftId,
    this.cashierId,
    this.cashierName,
    this.createdBy = 'cashier',
    this.note,
  });

  final String id;
  final String? shiftId;
  final String? cashierId;
  final String? cashierName;

  /// `cashier` | `admin`.
  final String createdBy;
  final String name;
  final int amountUzs;
  final ExpensePaidFrom paidFrom;
  final String? note;
  final DateTime spentAt;
  final DateTime createdAt;

  bool get isFromCash => paidFrom == ExpensePaidFrom.cash;

  factory BarExpense.fromJson(Map<String, dynamic> json) {
    final createdAt = readDate(json['createdAt']);
    final note = readStringOrNull(json['note'])?.trim();
    return BarExpense(
      id: json['id'] as String,
      shiftId: readStringOrNull(json['shiftId']),
      cashierId: readStringOrNull(json['cashierId']),
      cashierName: readStringOrNull(json['cashierName']),
      createdBy: readString(json['createdBy'], fallback: 'cashier'),
      name: readString(json['name']),
      amountUzs: readInt(json['amountUzs']),
      paidFrom: ExpensePaidFrom.fromApi(json['paidFrom']),
      note: note == null || note.isEmpty ? null : note,
      spentAt: readDateOrNull(json['spentAt']) ?? createdAt,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    shiftId,
    cashierId,
    cashierName,
    createdBy,
    name,
    amountUzs,
    paidFrom,
    note,
    spentAt,
    createdAt,
  ];
}

/// One "quick add" chip: a name this bar used recently and its last amount.
class ExpenseSuggestion extends Equatable {
  const ExpenseSuggestion({
    required this.name,
    required this.lastAmountUzs,
    this.count = 0,
  });

  final String name;
  final int lastAmountUzs;
  final int count;

  factory ExpenseSuggestion.fromJson(Map<String, dynamic> json) =>
      ExpenseSuggestion(
        name: readString(json['name']),
        lastAmountUzs: readInt(json['lastAmountUzs']),
        count: readInt(json['count']),
      );

  @override
  List<Object?> get props => [name, lastAmountUzs, count];
}

/// The shift's expense total and its cash-drawer part, summed locally from
/// the list (what the expenses screen header shows).
({int totalUzs, int cashUzs}) expenseTotalsOf(Iterable<BarExpense> expenses) {
  var total = 0;
  var cash = 0;
  for (final expense in expenses) {
    total += expense.amountUzs;
    if (expense.isFromCash) cash += expense.amountUzs;
  }
  return (totalUzs: total, cashUzs: cash);
}
