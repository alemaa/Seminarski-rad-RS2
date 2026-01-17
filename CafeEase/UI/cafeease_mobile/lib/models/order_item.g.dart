// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
      productId: (json['productId'] as num?)?.toInt(),
      quantity: (json['quantity'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
      'productId': instance.productId,
      'quantity': instance.quantity,
    };
