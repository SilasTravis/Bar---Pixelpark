import 'package:equatable/equatable.dart';

import '../../../core/utils/json_read.dart';
import '../../auth/domain/entities/bar_cashier.dart';

/// How a sale was paid: all cash, all card, or [mixed] — one cash part and
/// one card part that add up to the total. No balance.
enum PaymentMethod {
  cash('cash'),
  card('card'),
  mixed('mixed');

  const PaymentMethod(this.apiValue);

  final String apiValue;

  static PaymentMethod fromApi(Object? value) => switch (value) {
    'card' => PaymentMethod.card,
    'mixed' => PaymentMethod.mixed,
    _ => PaymentMethod.cash,
  };
}

/// The payment part of `POST /v1/bar/sales`. For [PaymentMethod.mixed] only
/// the cash part is sent; the server derives `card = total − cash`.
class SalePayment extends Equatable {
  const SalePayment.cash() : method = PaymentMethod.cash, cashUzs = null;

  const SalePayment.card() : method = PaymentMethod.card, cashUzs = null;

  /// `0 < cashUzs < total` — checked by the caller (the split dialog and
  /// `SaleCubit.checkoutMixed`) and again by the server
  /// (`BAR_INVALID_PAYMENT_SPLIT`).
  const SalePayment.mixed({required int this.cashUzs})
    : method = PaymentMethod.mixed;

  final PaymentMethod method;

  /// Only for [PaymentMethod.mixed].
  final int? cashUzs;

  /// `paymentMethod` (+ `cashUzs` for a split) of the sale request body.
  Map<String, dynamic> toRequestFields() => {
    'paymentMethod': method.apiValue,
    if (method == PaymentMethod.mixed) 'cashUzs': cashUzs,
  };

  @override
  List<Object?> get props => [method, cashUzs];
}

/// The cash and card parts of a sale. Servers that predate split payments
/// send neither field, so a missing part is derived from the method and the
/// total (a missing half of a split is `total − the other half`).
({int cashUzs, int cardUzs}) paymentPartsOf({
  required PaymentMethod method,
  required int totalUzs,
  int? cashUzs,
  int? cardUzs,
}) {
  if (cashUzs != null && cardUzs != null) {
    return (cashUzs: cashUzs, cardUzs: cardUzs);
  }
  if (cashUzs != null) return (cashUzs: cashUzs, cardUzs: totalUzs - cashUzs);
  if (cardUzs != null) return (cashUzs: totalUzs - cardUzs, cardUzs: cardUzs);
  return switch (method) {
    PaymentMethod.cash => (cashUzs: totalUzs, cardUzs: 0),
    PaymentMethod.card => (cashUzs: 0, cardUzs: totalUzs),
    // A split with neither part is a broken payload; show nothing rather
    // than invent a split.
    PaymentMethod.mixed => (cashUzs: 0, cardUzs: 0),
  };
}

enum SaleStatus {
  completed,
  refunded;

  static SaleStatus fromApi(Object? value) =>
      value == 'refunded' ? SaleStatus.refunded : SaleStatus.completed;
}

/// `BarSaleItem = { productId, name, priceUzs, quantity, lineTotalUzs }`
/// (name and price are snapshots taken at sale time).
class BarSaleItem extends Equatable {
  const BarSaleItem({
    required this.productId,
    required this.name,
    required this.priceUzs,
    required this.quantity,
    required this.lineTotalUzs,
  });

  final String productId;
  final String name;
  final int priceUzs;
  final int quantity;
  final int lineTotalUzs;

  factory BarSaleItem.fromJson(Map<String, dynamic> json) => BarSaleItem(
    productId: readString(json['productId']),
    name: readString(json['name']),
    priceUzs: readInt(json['priceUzs']),
    quantity: readInt(json['quantity']),
    lineTotalUzs: readInt(json['lineTotalUzs']),
  );

  @override
  List<Object?> get props => [
    productId,
    name,
    priceUzs,
    quantity,
    lineTotalUzs,
  ];
}

/// `BarSale` from the bar API.
class BarSale extends Equatable {
  const BarSale({
    required this.id,
    required this.receiptNo,
    required this.bar,
    required this.shiftId,
    required this.cashierId,
    required this.cashierName,
    required this.paymentMethod,
    required this.totalUzs,
    required this.cashUzs,
    required this.cardUzs,
    required this.status,
    required this.createdAt,
    required this.items,
    this.refundedAt,
    this.refundedBy,
    this.refundReason,
  });

  final String id;
  final int receiptNo;
  final BarRef bar;
  final String shiftId;
  final String cashierId;
  final String cashierName;
  final PaymentMethod paymentMethod;
  final int totalUzs;

  /// The cash / card parts of [totalUzs] (the whole total on one side for a
  /// plain cash or card sale).
  final int cashUzs;
  final int cardUzs;
  final SaleStatus status;
  final DateTime createdAt;
  final List<BarSaleItem> items;
  final DateTime? refundedAt;

  /// `cashier` | `admin` | null.
  final String? refundedBy;
  final String? refundReason;

  bool get isRefunded => status == SaleStatus.refunded;

  bool get isMixed => paymentMethod == PaymentMethod.mixed;

  factory BarSale.fromJson(Map<String, dynamic> json) {
    final paymentMethod = PaymentMethod.fromApi(json['paymentMethod']);
    final totalUzs = readInt(json['totalUzs']);
    final parts = paymentPartsOf(
      method: paymentMethod,
      totalUzs: totalUzs,
      cashUzs: readIntOrNull(json['cashUzs']),
      cardUzs: readIntOrNull(json['cardUzs']),
    );
    return BarSale(
      id: json['id'] as String,
      receiptNo: readInt(json['receiptNo']),
      bar: BarRef.fromJson(readMap(json['bar'])),
      shiftId: readString(json['shiftId']),
      cashierId: readString(json['cashierId']),
      cashierName: readString(json['cashierName']),
      paymentMethod: paymentMethod,
      totalUzs: totalUzs,
      cashUzs: parts.cashUzs,
      cardUzs: parts.cardUzs,
      status: SaleStatus.fromApi(json['status']),
      createdAt: readDate(json['createdAt']),
      items: readMapList(json['items']).map(BarSaleItem.fromJson).toList(),
      refundedAt: readDateOrNull(json['refundedAt']),
      refundedBy: readStringOrNull(json['refundedBy']),
      refundReason: readStringOrNull(json['refundReason']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    receiptNo,
    bar,
    shiftId,
    cashierId,
    cashierName,
    paymentMethod,
    totalUzs,
    cashUzs,
    cardUzs,
    status,
    createdAt,
    items,
    refundedAt,
    refundedBy,
    refundReason,
  ];
}
