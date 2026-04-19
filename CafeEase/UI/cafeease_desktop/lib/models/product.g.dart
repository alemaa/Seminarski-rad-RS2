// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  price: (json['price'] as num?)?.toDouble(),
  description: json['description'] as String?,
  imagePath: json['imagePath'] as String?,
  categoryId: (json['categoryId'] as num?)?.toInt(),
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'description': instance.description,
  'imagePath': instance.imagePath,
  'categoryId': instance.categoryId,
};
