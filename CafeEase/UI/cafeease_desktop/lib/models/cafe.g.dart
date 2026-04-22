// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cafe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cafe _$CafeFromJson(Map<String, dynamic> json) => Cafe(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  address: json['address'] as String?,
  cityName: json['cityName'] as String?,
  cityId: (json['cityId'] as num?)?.toInt(),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  phoneNumber: json['phoneNumber'] as String?,
  workingHours: json['workingHours'] as String?,
  isActive: json['isActive'] as bool?,
  distanceKm: (json['distanceKm'] as num?)?.toDouble(),
);

Map<String, dynamic> _$CafeToJson(Cafe instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'cityName': instance.cityName,
  'cityId': instance.cityId,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'phoneNumber': instance.phoneNumber,
  'workingHours': instance.workingHours,
  'isActive': instance.isActive,
  'distanceKm': instance.distanceKm,
};
