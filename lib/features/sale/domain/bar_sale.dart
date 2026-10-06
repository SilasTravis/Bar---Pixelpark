import 'package:equatable/equatable.dart';

import '../../../core/utils/json_read.dart';
import '../../auth/domain/entities/bar_cashier.dart';

/// One method per sale — no split payments, no balance.
enum PaymentMethod {
  cash('cash'),
  card('card');

  const PaymentMethod(this.apiValue);

  final String apiValue;

  static PaymentMethod fromApi(Object? value) =>
      value == 'card' ? PaymentMethod.card : PaymentMethod.cash;
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
  final SaleStatus status;
  final DateTime createdAt;
  final List<BarSaleItem> items;
  final DateTime? refundedAt;

  /// `cashier` | `admin` | null.
  final String? refundedBy;
  final String? refundReason;

  bool get isRefunded => status == SaleStatus.refunded;

  factory BarSale.fromJson(Map<String, dynamic> json) => BarSale(
    id: json['id'] as String,
    receiptNo: readInt(json['receiptNo']),
    bar: BarRef.fromJson(readMap(json['bar'])),
    shiftId: readString(json['shiftId']),
    cashierId: readString(json['cashierId']),
    cashierName: readString(json['cashierName']),
    paymentMethod: PaymentMethod.fromApi(json['paymentMethod']),
    totalUzs: readInt(json['totalUzs']),
    status: SaleStatus.fromApi(json['status']),
    createdAt: readDate(json['createdAt']),
    items: readMapList(json['items']).map(BarSaleItem.fromJson).toList(),
    refundedAt: readDateOrNull(json['refundedAt']),
    refundedBy: readStringOrNull(json['refundedBy']),
    refundReason: readStringOrNull(json['refundReason']),
  );

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
    status,
    createdAt,
    items,
    refundedAt,
    refundedBy,
    refundReason,
  ];
}
