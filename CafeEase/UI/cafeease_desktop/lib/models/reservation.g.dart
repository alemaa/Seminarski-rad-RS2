// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reservation _$ReservationFromJson(Map<String, dynamic> json) => Reservation(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['userId'] as num).toInt(),
  tableId: (json['tableId'] as num).toInt(),
  tableNumber: (json['tableNumber'] as num?)?.toInt(),
  reservationDateTime: DateTime.parse(json['reservationDateTime'] as String),
  numberOfGuests: (json['numberOfGuests'] as num).toInt(),
  status: json['status'] as String,
);

Map<String, dynamic> _$ReservationToJson(Reservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'tableId': instance.tableId,
      'tableNumber': instance.tableNumber,
      'reservationDateTime': instance.reservationDateTime.toIso8601String(),
      'numberOfGuests': instance.numberOfGuests,
      'status': instance.status,
    };
