import 'package:equatable/equatable.dart';

import '../../../../core/utils/json_read.dart';

/// `BarRef = { id, name }`.
class BarRef extends Equatable {
  const BarRef({required this.id, required this.name});

  final String id;
  final String name;

  factory BarRef.fromJson(Map<String, dynamic> json) =>
      BarRef(id: readString(json['id']), name: readString(json['name']));

  @override
  List<Object?> get props => [id, name];
}

/// `BarCashier = { id, fullName, username, bar: BarRef }`.
class BarCashier extends Equatable {
  const BarCashier({
    required this.id,
    required this.fullName,
    required this.username,
    required this.bar,
  });

  final String id;
  final String fullName;
  final String username;
  final BarRef bar;

  factory BarCashier.fromJson(Map<String, dynamic> json) => BarCashier(
    id: json['id'] as String,
    fullName: readString(json['fullName']),
    username: readString(json['username']),
    bar: BarRef.fromJson(readMap(json['bar'])),
  );

  @override
  List<Object?> get props => [id, fullName, username, bar];
}
