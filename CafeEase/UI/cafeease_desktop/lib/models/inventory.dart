import 'package:json_annotation/json_annotation.dart';

part 'inventory.g.dart';

@JsonSerializable()
class Inventory {
  int? id;
  int? productId;
  int? quantity;
  String? productName;

  Inventory({this.id, this.productId, this.quantity, this.productName});

  factory Inventory.fromJson(Map<String, dynamic> json) =>
      _$InventoryFromJson(json);

  Map<String, dynamic> toJson() => _$InventoryToJson(this);
}
