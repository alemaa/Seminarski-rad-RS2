import 'package:json_annotation/json_annotation.dart';

part 'order_item.g.dart';

@JsonSerializable()
class OrderItem {
  int? id;
  int? orderId;
  int? productId;
  String? productName;
  int? quantity;
  double? price;

  OrderItem({
    this.id,
    this.orderId,
    this.productId,
    this.productName,
    this.quantity,
    this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemToJson(this);

  double get lineTotal => (price ?? 0) * (quantity ?? 0);
}
