import 'package:equatable/equatable.dart';

import '../../../core/utils/json_read.dart';

/// `BarProduct = { id, name, category, icon, imageUrl?, priceUzs, sortOrder }`.
class BarProduct extends Equatable {
  const BarProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.priceUzs,
    this.sortOrder = 0,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String category;

  /// Phosphor icon class name, same convention as POS products
  /// (`ph ph-coffee`, `ph-coffee` or plain `coffee`). Also the tile's
  /// fallback while [imageUrl] loads or when it fails.
  final String icon;
  final int priceUzs;
  final int sortOrder;

  /// Absolute `http(s)` URL of the product photo, or null when the product
  /// has none — or the server predates the field.
  final String? imageUrl;

  factory BarProduct.fromJson(Map<String, dynamic> json) => BarProduct(
    id: json['id'] as String,
    name: readString(json['name']),
    category: readString(json['category']).trim(),
    icon: readString(json['icon']),
    priceUzs: readInt(json['priceUzs']),
    sortOrder: readInt(json['sortOrder']),
    imageUrl: _readImageUrl(json['imageUrl']),
  );

  /// Missing, null, blank or non-http(s) → null: a bad value must only ever
  /// cost the photo (the icon shows instead), never the catalog.
  static String? _readImageUrl(Object? value) {
    final raw = readStringOrNull(value)?.trim();
    if (raw == null || raw.isEmpty) return null;
    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasAuthority) return null;
    return (uri.scheme == 'https' || uri.scheme == 'http') ? raw : null;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    icon,
    priceUzs,
    sortOrder,
    imageUrl,
  ];
}
