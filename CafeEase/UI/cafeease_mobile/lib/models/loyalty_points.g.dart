// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loyalty_points.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoyaltyPoints _$LoyaltyPointsFromJson(Map<String, dynamic> json) =>
    LoyaltyPoints(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      points: (json['points'] as num).toInt(),
    );

Map<String, dynamic> _$LoyaltyPointsToJson(LoyaltyPoints instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'points': instance.points,
    };
