import 'package:equatable/equatable.dart';

import '../../../core/utils/json_read.dart';
import '../../auth/domain/entities/bar_cashier.dart';

/// `BarShift` from the bar API. Totals are computed server-side from
/// completed sales, so a refund corrects them immediately.
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
    this.countedCashUzs,
    this.cashDifferenceUzs,
    this.note,
  });

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

  /// Null until the shift is closed.
  final int? countedCashUzs;

  /// `countedCashUzs - cashTotalUzs`; null until closed.
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
    countedCashUzs,
    cashDifferenceUzs,
    note,
  ];
}

/// The live "farq" on the close-shift screen: counted cash minus what the
/// shift's cash sales say should be in the drawer. Same formula as the
/// backend's `cashDifferenceUzs`. Null while nothing is typed.
int? cashDifference({
  required int? countedCashUzs,
  required int cashTotalUzs,
}) => countedCashUzs == null ? null : countedCashUzs - cashTotalUzs;
