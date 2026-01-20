// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Table _$TableFromJson(Map<String, dynamic> json) => Table(
      id: (json['id'] as num?)?.toInt(),
      number: (json['number'] as num?)?.toInt(),
      capacity: (json['capacity'] as num?)?.toInt(),
      isOccupied: json['isOccupied'] as bool?,
    );

Map<String, dynamic> _$TableToJson(Table instance) => <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'capacity': instance.capacity,
      'isOccupied': instance.isOccupied,
    };
