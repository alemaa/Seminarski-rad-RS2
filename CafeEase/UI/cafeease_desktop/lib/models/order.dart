import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  int? id;
  DateTime? orderDate;
  double? totalAmount;
  String? status;
  int? userId;
  int? tableId;

  Order({
    this.id,
    this.orderDate,
    this.totalAmount,
    this.status,
    this.userId,
    this.tableId,
  });

  factory Order.fromJson(Map<String, dynamic> json) =>
      _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
