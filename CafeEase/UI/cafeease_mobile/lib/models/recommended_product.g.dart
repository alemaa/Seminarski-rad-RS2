// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommended_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendedProduct _$RecommendedProductFromJson(Map<String, dynamic> json) =>
    RecommendedProduct(
      product: json['product'] == null
          ? null
          : Product.fromJson(json['product'] as Map<String, dynamic>),
      score: (json['score'] as num?)?.toDouble(),
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$RecommendedProductToJson(RecommendedProduct instance) =>
    <String, dynamic>{
      'product': instance.product,
      'score': instance.score,
      'reason': instance.reason,
    };
