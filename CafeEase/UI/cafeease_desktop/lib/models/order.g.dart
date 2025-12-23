// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: (json['id'] as num?)?.toInt(),
  orderDate: json['orderDate'] == null
      ? null
      : DateTime.parse(json['orderDate'] as String),
  totalAmount: (json['totalAmount'] as num?)?.toDouble(),
  status: json['status'] as String?,
  userId: (json['userId'] as num?)?.toInt(),
  tableId: (json['tableId'] as num?)?.toInt(),
  userFullName: json['userFullName'] as String?,
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'orderDate': instance.orderDate?.toIso8601String(),
  'totalAmount': instance.totalAmount,
  'status': instance.status,
  'userId': instance.userId,
  'tableId': instance.tableId,
  'userFullName': instance.userFullName,
};
