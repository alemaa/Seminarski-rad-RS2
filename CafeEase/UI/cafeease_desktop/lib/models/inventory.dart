import 'package:json_annotation/json_annotation.dart';

part 'inventory.g.dart';

@JsonSerializable()
class Inventory {
  int? id;
  int? productId;
  int? quantity;

  Inventory({this.id, this.productId, this.quantity});

  factory Inventory.fromJson(Map<String, dynamic> json) =>
      _$InventoryFromJson(json);

  Map<String, dynamic> toJson() => _$InventoryToJson(this);
}
