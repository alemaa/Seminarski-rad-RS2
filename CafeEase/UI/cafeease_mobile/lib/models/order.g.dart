// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      id: (json['id'] as num?)?.toInt(),
      status: json['status'] as String?,
      orderDate: json['orderDate'] == null
          ? null
          : DateTime.parse(json['orderDate'] as String),
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      tableId: (json['tableId'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'orderDate': instance.orderDate?.toIso8601String(),
      'totalAmount': instance.totalAmount,
      'tableId': instance.tableId,
      'userId': instance.userId,
      'items': instance.items,
    };
