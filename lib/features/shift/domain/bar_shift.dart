import 'package:equatable/equatable.dart';

import '../../../core/utils/json_read.dart';
import '../../auth/domain/entities/bar_cashier.dart';

/// `BarShift` from the bar API. Totals are computed server-side from
/// completed sales (and non-deleted expenses), so a refund or a deleted
/// expense corrects them immediately.
class BarShift extends Equatable {
  const BarShift({
    required this.id,
    required this.bar,
    required this.cashierId,
    required this.cashierName,
    required this.openedAt,
    this.closedAt,
    this.cashTotalUzs = 0,
    this.cardTotalUzs = 0,
    this.totalUzs = 0,
    this.salesCount = 0,
    this.refundedCount = 0,
    this.expensesUzs = 0,
    this.cashExpensesUzs = 0,
    this.incomesUzs = 0,
    this.cashIncomesUzs = 0,
    int? expectedCashUzs,
    this.countedCashUzs,
    this.cashDifferenceUzs,
    this.note,
  }) : // Same formula as [expectedCashOf] (a const constructor cannot
       // call it).
       expectedCashUzs =
           expectedCashUzs ?? cashTotalUzs - cashExpensesUzs + cashIncomesUzs;

  final String id;
  final BarRef bar;
  final String cashierId;
  final String cashierName;
  final DateTime openedAt;
  final DateTime? closedAt;
  final int cashTotalUzs;
  final int cardTotalUzs;
  final int totalUzs;
  final int salesCount;
  final int refundedCount;

  /// All of the shift's (non-deleted) expenses; 0 on a backend without
  /// expenses.
  final int expensesUzs;

  /// The part of [expensesUzs] taken from the cash drawer.
  final int cashExpensesUzs;

  /// All of the shift's (non-deleted) incomes ("kirim"); 0 on a backend
  /// without incomes.
  final int incomesUzs;

  /// The part of [incomesUzs] put into the cash drawer.
  final int cashIncomesUzs;

  /// Cash that must be in the drawer:
  /// `cashTotalUzs − cashExpensesUzs + cashIncomesUzs`. Derived locally when
  /// the backend does not send it.
  final int expectedCashUzs;

  /// Null until the shift is closed.
  final int? countedCashUzs;

  /// `countedCashUzs - expectedCashUzs`; null until closed.
  final int? cashDifferenceUzs;
  final String? note;

  bool get isOpen => closedAt == null;

  factory BarShift.fromJson(Map<String, dynamic> json) => BarShift(
    id: json['id'] as String,
    bar: BarRef.fromJson(readMap(json['bar'])),
    cashierId: readString(json['cashierId']),
    cashierName: readString(json['cashierName']),
    openedAt: readDate(json['openedAt']),
    closedAt: readDateOrNull(json['closedAt']),
    cashTotalUzs: readInt(json['cashTotalUzs']),
    cardTotalUzs: readInt(json['cardTotalUzs']),
    totalUzs: readInt(json['totalUzs']),
    salesCount: readInt(json['salesCount']),
    refundedCount: readInt(json['refundedCount']),
    expensesUzs: readInt(json['expensesUzs']),
    cashExpensesUzs: readInt(json['cashExpensesUzs']),
    incomesUzs: readInt(json['incomesUzs']),
    cashIncomesUzs: readInt(json['cashIncomesUzs']),
    expectedCashUzs: readIntOrNull(json['expectedCashUzs']),
    countedCashUzs: readIntOrNull(json['countedCashUzs']),
    cashDifferenceUzs: readIntOrNull(json['cashDifferenceUzs']),
    note: readStringOrNull(json['note']),
  );

  /// `GET /v1/bar/shifts/current` → `{ shift: BarShift | null }`.
  static BarShift? fromCurrentResponse(Map<String, dynamic> json) {
    final shift = json['shift'];
    return shift is Map
        ? BarShift.fromJson(Map<String, dynamic>.from(shift))
        : null;
  }

  @override
  List<Object?> get props => [
    id,
    bar,
    cashierId,
    cashierName,
    openedAt,
    closedAt,
    cashTotalUzs,
    cardTotalUzs,
    totalUzs,
    salesCount,
    refundedCount,
    expensesUzs,
    cashExpensesUzs,
    incomesUzs,
    cashIncomesUzs,
    expectedCashUzs,
    countedCashUzs,
    cashDifferenceUzs,
    note,
  ];
}

/// Cash that should be in the drawer: cash sales minus the expenses paid
/// from the drawer plus the incomes put into it. Same formula as the
/// backend's `expectedCashUzs`.
int expectedCashOf({
  required int cashTotalUzs,
  required int cashExpensesUzs,
  int cashIncomesUzs = 0,
}) => cashTotalUzs - cashExpensesUzs + cashIncomesUzs;

/// The live "farq" on the close-shift screen: counted cash minus what
/// should be in the drawer ([BarShift.expectedCashUzs]). Same formula as the
/// backend's `cashDifferenceUzs`. Null while nothing is typed.
int? cashDifference({
  required int? countedCashUzs,
  required int expectedCashUzs,
}) => countedCashUzs == null ? null : countedCashUzs - expectedCashUzs;
