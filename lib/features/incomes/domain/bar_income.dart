import 'package:equatable/equatable.dart';

import '../../../core/utils/json_read.dart';

/// Where the money of an income came from. [cash] was put into the bar's
/// drawer, so it raises the cash the cashier hands over at shift close;
/// [other] was received outside the drawer (owner, card, transfer).
enum IncomeReceivedTo {
  cash('cash'),
  other('other');

  const IncomeReceivedTo(this.apiValue);

  final String apiValue;

  static IncomeReceivedTo fromApi(Object? value) =>
      value == 'other' ? IncomeReceivedTo.other : IncomeReceivedTo.cash;
}

/// The amount limits of `POST /v1/bar/incomes` (`amountUzs` 1..1 000 000 000).
abstract final class IncomeLimits {
  static const int maxAmountUzs = 1000000000;
  static const int maxNameLength = 150;
  static const int maxNoteLength = 300;
}

/// `BarIncome` from the bar API ("kirim": e.g. "Depozit" 25 000 so'm).
class BarIncome extends Equatable {
  const BarIncome({
    required this.id,
    required this.name,
    required this.amountUzs,
    required this.receivedTo,
    required this.receivedAt,
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
  final IncomeReceivedTo receivedTo;
  final String? note;
  final DateTime receivedAt;
  final DateTime createdAt;

  bool get isToCash => receivedTo == IncomeReceivedTo.cash;

  factory BarIncome.fromJson(Map<String, dynamic> json) {
    final createdAt = readDate(json['createdAt']);
    final note = readStringOrNull(json['note'])?.trim();
    return BarIncome(
      id: json['id'] as String,
      shiftId: readStringOrNull(json['shiftId']),
      cashierId: readStringOrNull(json['cashierId']),
      cashierName: readStringOrNull(json['cashierName']),
      createdBy: readString(json['createdBy'], fallback: 'cashier'),
      name: readString(json['name']),
      amountUzs: readInt(json['amountUzs']),
      receivedTo: IncomeReceivedTo.fromApi(json['receivedTo']),
      note: note == null || note.isEmpty ? null : note,
      receivedAt: readDateOrNull(json['receivedAt']) ?? createdAt,
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
    receivedTo,
    note,
    receivedAt,
    createdAt,
  ];
}

/// One "quick add" chip: a name this bar used recently and its last amount.
class IncomeSuggestion extends Equatable {
  const IncomeSuggestion({
    required this.name,
    required this.lastAmountUzs,
    this.count = 0,
  });

  final String name;
  final int lastAmountUzs;
  final int count;

  factory IncomeSuggestion.fromJson(Map<String, dynamic> json) =>
      IncomeSuggestion(
        name: readString(json['name']),
        lastAmountUzs: readInt(json['lastAmountUzs']),
        count: readInt(json['count']),
      );

  @override
  List<Object?> get props => [name, lastAmountUzs, count];
}

/// The shift's income total and its cash-drawer part, summed locally from
/// the list (what the incomes screen header shows).
({int totalUzs, int cashUzs}) incomeTotalsOf(Iterable<BarIncome> incomes) {
  var total = 0;
  var cash = 0;
  for (final income in incomes) {
    total += income.amountUzs;
    if (income.isToCash) cash += income.amountUzs;
  }
  return (totalUzs: total, cashUzs: cash);
}
