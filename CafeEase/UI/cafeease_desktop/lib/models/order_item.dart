import 'package:json_annotation/json_annotation.dart';

part 'order_item.g.dart';

@JsonSerializable()
class OrderItem {
  int? id;
  int? orderId;
  int? productId;
  int? quantity;
  double? price;
  String? productName;
  String? size;
  String? milkType;
  int? sugarLevel;
  String? note;


  OrderItem({
    this.id,
    this.orderId,
    this.productId,
    this.quantity,
    this.price,
    this.productName,
    this.size,
    this.milkType,
    this.sugarLevel,
    this.note
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}
