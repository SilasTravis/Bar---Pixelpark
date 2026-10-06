import 'package:equatable/equatable.dart';

import '../../../core/utils/json_read.dart';

/// `BarProduct = { id, name, category, icon, priceUzs, sortOrder }`.
class BarProduct extends Equatable {
  const BarProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.priceUzs,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String category;

  /// Phosphor icon class name, same convention as POS products
  /// (`ph ph-coffee`, `ph-coffee` or plain `coffee`).
  final String icon;
  final int priceUzs;
  final int sortOrder;

  factory BarProduct.fromJson(Map<String, dynamic> json) => BarProduct(
    id: json['id'] as String,
    name: readString(json['name']),
    category: readString(json['category']).trim(),
    icon: readString(json['icon']),
    priceUzs: readInt(json['priceUzs']),
    sortOrder: readInt(json['sortOrder']),
  );

  @override
  List<Object?> get props => [id, name, category, icon, priceUzs, sortOrder];
}
