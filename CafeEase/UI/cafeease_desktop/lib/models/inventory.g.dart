// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Inventory _$InventoryFromJson(Map<String, dynamic> json) => Inventory(
  id: (json['id'] as num?)?.toInt(),
  productId: (json['productId'] as num?)?.toInt(),
  quantity: (json['quantity'] as num?)?.toInt(),
);

Map<String, dynamic> _$InventoryToJson(Inventory instance) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'quantity': instance.quantity,
};
