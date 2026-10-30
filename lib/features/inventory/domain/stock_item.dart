import 'package:equatable/equatable.dart';

import '../../../core/utils/json_read.dart';

/// Stock is kept in integer base units: grams, millilitres or pieces.
enum StockUnit {
  g('g'),
  ml('ml'),
  pcs('pcs');

  const StockUnit(this.apiValue);

  final String apiValue;

  static StockUnit parse(Object? value) => StockUnit.values.firstWhere(
    (u) => u.apiValue == value,
    orElse: () => StockUnit.pcs,
  );

  /// Short label shown next to a quantity in this unit's base.
  String get baseLabel => switch (this) {
    StockUnit.g => 'g',
    StockUnit.ml => 'ml',
    StockUnit.pcs => 'dona',
  };

  /// The larger input unit (kg / l), or null for pieces.
  String? get bigLabel => switch (this) {
    StockUnit.g => 'kg',
    StockUnit.ml => 'l',
    StockUnit.pcs => null,
  };
}

enum StockStatus { ok, low, out }

/// `{ id, name, unit, qtyOnHand, minQty, active, status? }`. [status] is
/// derived when the server does not send it.
class StockItem extends Equatable {
  const StockItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.qtyOnHand,
    required this.minQty,
    this.active = true,
  });

  final String id;
  final String name;
  final StockUnit unit;
  final int qtyOnHand;
  final int minQty;
  final bool active;

  StockStatus get status => qtyOnHand <= 0
      ? StockStatus.out
      : (qtyOnHand <= minQty ? StockStatus.low : StockStatus.ok);

  factory StockItem.fromJson(Map<String, dynamic> json) => StockItem(
    id: readString(json['id']),
    name: readString(json['name']),
    unit: StockUnit.parse(json['unit']),
    qtyOnHand: readInt(json['qtyOnHand']),
    minQty: readInt(json['minQty']),
    active: json['active'] is bool ? json['active'] as bool : true,
  );

  @override
  List<Object?> get props => [id, name, unit, qtyOnHand, minQty, active];
}

class StockPage extends Equatable {
  const StockPage({
    required this.items,
    required this.total,
    required this.page,
  });

  final List<StockItem> items;
  final int total;
  final int page;

  factory StockPage.fromJson(Map<String, dynamic> json) {
    final items = readMapList(json['items']).map(StockItem.fromJson).toList();
    return StockPage(
      items: items,
      total: readInt(json['total'], fallback: items.length),
      page: readInt(json['page'], fallback: 1),
    );
  }

  @override
  List<Object?> get props => [items, total, page];
}

enum StockMovementType {
  receipt,
  sale,
  refund,
  writeoff,
  adjustment,
  other;

  static StockMovementType parse(Object? value) =>
      StockMovementType.values.firstWhere(
        (t) => t.name == value,
        orElse: () => StockMovementType.other,
      );
}

class StockMovement extends Equatable {
  const StockMovement({
    required this.id,
    required this.stockItemId,
    required this.type,
    required this.qtyDelta,
    required this.createdAt,
    this.stockItemName = '',
    this.reason,
  });

  final String id;
  final String stockItemId;
  final String stockItemName;
  final StockMovementType type;
  final int qtyDelta;
  final String? reason;
  final DateTime createdAt;

  factory StockMovement.fromJson(Map<String, dynamic> json) => StockMovement(
    id: readString(json['id']),
    stockItemId: readString(json['stockItemId']),
    stockItemName: readString(json['stockItemName']),
    type: StockMovementType.parse(json['type']),
    qtyDelta: readInt(json['qtyDelta']),
    reason: readStringOrNull(json['reason']),
    createdAt: readDate(json['createdAt']),
  );

  @override
  List<Object?> get props => [
    id,
    stockItemId,
    stockItemName,
    type,
    qtyDelta,
    reason,
    createdAt,
  ];
}

class MovementsPage extends Equatable {
  const MovementsPage({required this.items, required this.total});

  final List<StockMovement> items;
  final int total;

  factory MovementsPage.fromJson(Map<String, dynamic> json) {
    final items = readMapList(
      json['items'],
    ).map(StockMovement.fromJson).toList();
    return MovementsPage(
      items: items,
      total: readInt(json['total'], fallback: items.length),
    );
  }

  @override
  List<Object?> get props => [items, total];
}

enum ProductKind {
  ready,
  prepared;

  static ProductKind parse(Object? value) =>
      value == 'ready' ? ProductKind.ready : ProductKind.prepared;
}

/// One ingredient: [qty] base units per portion (prepared) or per unit sold
/// (ready).
class RecipeLine extends Equatable {
  const RecipeLine({required this.stockItemId, required this.qty});

  final String stockItemId;
  final int qty;

  @override
  List<Object?> get props => [stockItemId, qty];
}

/// `GET/PUT /bar/inventory/products/:id/setup`. [addonIds] is carried
/// through untouched: this app does not edit add-ons.
class ProductSetup extends Equatable {
  const ProductSetup({
    required this.productId,
    required this.kind,
    this.link,
    this.recipe = const [],
    this.addonIds = const [],
  });

  final String productId;
  final ProductKind kind;

  /// `ready` only.
  final RecipeLine? link;

  /// `prepared` only.
  final List<RecipeLine> recipe;
  final List<String> addonIds;

  bool get isEmpty => kind == ProductKind.ready ? link == null : recipe.isEmpty;

  factory ProductSetup.fromJson(String productId, Map<String, dynamic> json) {
    final link = readMap(json['link']);
    return ProductSetup(
      productId: productId,
      kind: ProductKind.parse(json['kind']),
      link: link['stockItemId'] == null
          ? null
          : RecipeLine(
              stockItemId: readString(link['stockItemId']),
              qty: readInt(link['qtyPerUnit']),
            ),
      recipe: readMapList(json['recipe'])
          .map(
            (l) => RecipeLine(
              stockItemId: readString(l['stockItemId']),
              qty: readInt(l['qtyPerPortion']),
            ),
          )
          .toList(),
      addonIds: json['addonIds'] is List
          ? (json['addonIds'] as List).map((e) => e.toString()).toList()
          : const [],
    );
  }

  /// The `PUT` body: both halves are always sent (the server ignores the
  /// one that does not match [kind]); we send the inactive one empty.
  Map<String, dynamic> toRequest() => {
    'kind': kind.name,
    'link': kind == ProductKind.ready && link != null
        ? {'stockItemId': link!.stockItemId, 'qtyPerUnit': link!.qty}
        : null,
    'recipe': kind == ProductKind.prepared
        ? [
            for (final l in recipe)
              {'stockItemId': l.stockItemId, 'qtyPerPortion': l.qty},
          ]
        : <Map<String, dynamic>>[],
    'addonIds': addonIds,
  };

  @override
  List<Object?> get props => [productId, kind, link, recipe, addonIds];
}
