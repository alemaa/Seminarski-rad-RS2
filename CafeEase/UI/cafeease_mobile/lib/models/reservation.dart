import 'package:json_annotation/json_annotation.dart';

part 'reservation.g.dart';

@JsonSerializable()
class Reservation {
  int? id;
  int? userId;
  int? tableId;
  int? tableNumber;
  String? userFullName;
  String? userMail;
  DateTime? reservationDateTime;
  int? numberOfGuests;
  String? status;

  Reservation({
    this.id,
    this.userId,
    this.tableId,
    this.tableNumber,
    this.userFullName,
    this.userMail,
    this.reservationDateTime,
    this.numberOfGuests,
    this.status,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);

  Map<String, dynamic> toJson() => _$ReservationToJson(this);
}
