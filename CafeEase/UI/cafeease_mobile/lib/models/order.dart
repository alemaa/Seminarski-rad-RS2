import 'package:json_annotation/json_annotation.dart';
import 'order_item.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  int? id;
  String? status;
  DateTime? orderDate;
  double? totalAmount;
  int? tableId;
  int? userId;
  List<OrderItem>? items;

  Order({
    this.id,
    this.status,
    this.orderDate,
    this.totalAmount,
    this.tableId,
    this.userId,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
