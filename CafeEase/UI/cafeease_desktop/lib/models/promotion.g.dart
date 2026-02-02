// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Promotion _$PromotionFromJson(Map<String, dynamic> json) => Promotion(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  discountPercent: (json['discountPercent'] as num).toDouble(),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  categories: (json['categories'] as List<dynamic>)
      .map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList(),
  targetSegment: json['targetSegment'] as String?,
);

Map<String, dynamic> _$PromotionToJson(Promotion instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'discountPercent': instance.discountPercent,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'categories': instance.categories,
  'targetSegment': instance.targetSegment,
};
