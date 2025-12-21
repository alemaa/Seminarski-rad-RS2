// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  userFullName: json['userFullName'] as String?,
  productId: (json['productId'] as num).toInt(),
  productName: json['productName'] as String?,
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String?,
  dateCreated: DateTime.parse(json['dateCreated'] as String),
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userFullName': instance.userFullName,
  'productId': instance.productId,
  'productName': instance.productName,
  'rating': instance.rating,
  'comment': instance.comment,
  'dateCreated': instance.dateCreated.toIso8601String(),
};
