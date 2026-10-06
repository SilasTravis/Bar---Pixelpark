/// Lenient JSON readers for the backend's money/count fields. The contract
/// says JSON numbers, but Postgres `BIGINT` columns are easy to leak as
/// strings — accepting both keeps one serializer slip from breaking a till.
int readInt(Object? value, {int fallback = 0}) =>
    readIntOrNull(value) ?? fallback;

int? readIntOrNull(Object? value) => switch (value) {
  final int v => v,
  final num v => v.round(),
  final String v =>
    int.tryParse(v.trim()) ?? double.tryParse(v.trim())?.round(),
  _ => null,
};

DateTime readDate(Object? value) =>
    readDateOrNull(value) ??
    DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

DateTime? readDateOrNull(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

String readString(Object? value, {String fallback = ''}) =>
    value == null ? fallback : value.toString();

String? readStringOrNull(Object? value) => value?.toString();

Map<String, dynamic> readMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

List<Map<String, dynamic>> readMapList(Object? value) => value is List
    ? value.whereType<Map>().map(Map<String, dynamic>.from).toList()
    : const [];
