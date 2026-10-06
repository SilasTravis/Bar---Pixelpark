import 'package:equatable/equatable.dart';

import '../../products/domain/bar_product.dart';

class CartLine extends Equatable {
  const CartLine({required this.product, required this.quantity});

  final BarProduct product;
  final int quantity;

  int get lineTotalUzs => product.priceUzs * quantity;

  CartLine withQuantity(int quantity) =>
      CartLine(product: product, quantity: quantity);

  @override
  List<Object?> get props => [product, quantity];
}

/// The cart on the sale screen — immutable; every operation returns a new
/// cart.
///
/// It also owns the sale's idempotency key, [clientSaleId]:
/// * minted once, on the first checkout attempt ([withClientSaleId]);
/// * kept across failed attempts, so a retry after a dropped connection
///   sends the SAME id and the backend returns the sale it may already have
///   recorded instead of charging twice;
/// * dropped whenever the content (products or quantities) changes — that
///   is a different sale and gets a new id at its next checkout;
/// * gone after a successful sale, because the cart is replaced by
///   [Cart.empty].
class Cart extends Equatable {
  const Cart._(this.lines, this.clientSaleId);

  static const Cart empty = Cart._([], null);

  /// Backend limits: 1..999 per line, 1..100 lines per sale.
  static const int maxQuantity = 999;
  static const int maxLines = 100;

  final List<CartLine> lines;
  final String? clientSaleId;

  bool get isEmpty => lines.isEmpty;
  bool get isNotEmpty => lines.isNotEmpty;

  int get totalUzs => lines.fold(0, (sum, line) => sum + line.lineTotalUzs);

  int get itemCount => lines.fold(0, (sum, line) => sum + line.quantity);

  int quantityOf(String productId) {
    final index = _indexOf(productId);
    return index >= 0 ? lines[index].quantity : 0;
  }

  /// Adds one of [product]; a product already in the cart is incremented.
  Cart add(BarProduct product) {
    final index = _indexOf(product.id);
    if (index >= 0) return increment(product.id);
    if (lines.length >= maxLines) return this;
    return _changed([...lines, CartLine(product: product, quantity: 1)]);
  }

  Cart increment(String productId) {
    final index = _indexOf(productId);
    if (index < 0) return this;
    final line = lines[index];
    if (line.quantity >= maxQuantity) return this;
    return _replaceAt(index, line.withQuantity(line.quantity + 1));
  }

  /// One fewer; the line disappears when it reaches zero.
  Cart decrement(String productId) {
    final index = _indexOf(productId);
    if (index < 0) return this;
    final line = lines[index];
    if (line.quantity <= 1) return remove(productId);
    return _replaceAt(index, line.withQuantity(line.quantity - 1));
  }

  Cart remove(String productId) {
    if (_indexOf(productId) < 0) return this;
    return _changed([
      for (final line in lines)
        if (line.product.id != productId) line,
    ]);
  }

  Cart clear() => Cart.empty;

  /// The cart ready to submit: keeps the current [clientSaleId] if there is
  /// one (a retry), otherwise mints one with [generate].
  Cart withClientSaleId(String Function() generate) =>
      clientSaleId != null ? this : Cart._(lines, generate());

  /// Re-reads every line against a freshly loaded catalog: lines whose
  /// product is gone (deactivated, moved) are removed and prices/names are
  /// refreshed. Returns this exact cart when nothing changed, so the
  /// [clientSaleId] survives a routine product refresh.
  Cart syncWith(List<BarProduct> catalog) {
    if (lines.isEmpty) return this;
    final byId = {for (final product in catalog) product.id: product};
    final synced = <CartLine>[
      for (final line in lines)
        if (byId[line.product.id] case final product?)
          line.product == product
              ? line
              : CartLine(product: product, quantity: line.quantity),
    ];
    if (_sameLines(synced)) return this;
    return _changed(synced);
  }

  /// `items` of `POST /v1/bar/sales`.
  List<Map<String, dynamic>> toRequestItems() => [
    for (final line in lines)
      {'productId': line.product.id, 'quantity': line.quantity},
  ];

  int _indexOf(String productId) =>
      lines.indexWhere((line) => line.product.id == productId);

  Cart _replaceAt(int index, CartLine line) =>
      _changed([...lines]..[index] = line);

  /// Any content change is a different sale → the old id is dropped.
  Cart _changed(List<CartLine> newLines) =>
      newLines.isEmpty ? Cart.empty : Cart._(List.unmodifiable(newLines), null);

  bool _sameLines(List<CartLine> other) {
    if (other.length != lines.length) return false;
    for (var i = 0; i < other.length; i++) {
      if (other[i] != lines[i]) return false;
    }
    return true;
  }

  @override
  List<Object?> get props => [lines, clientSaleId];
}
