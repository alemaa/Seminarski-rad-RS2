import 'package:json_annotation/json_annotation.dart';

part 'table.g.dart';

@JsonSerializable()
class Table {
  int? id;
  int? number;
  int? capacity;
  bool? isOccupied;

Table({
  this.id,
  required this.number,
  required this.capacity,
  required this.isOccupied,
});

  factory Table.fromJson(Map<String, dynamic> json) =>
      _$TableFromJson(json);

  Map<String, dynamic> toJson() => _$TableToJson(this);
}
