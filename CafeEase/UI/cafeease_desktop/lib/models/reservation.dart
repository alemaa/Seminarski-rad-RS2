import 'package:json_annotation/json_annotation.dart';

part 'reservation.g.dart';

@JsonSerializable()
class Reservation {
  int? id;
  int userId;
  int tableId;
  int? tableNumber;
  DateTime reservationDateTime;
  int numberOfGuests;
  String status;
  String? userFullName;
  String? userEmail;
  DateTime? cancelledAt;
  String? cancellationReason;
  int? durationMinutes;

  Reservation({
    this.id,
    required this.userId,
    required this.tableId,
    required this.tableNumber,
    required this.reservationDateTime,
    required this.numberOfGuests,
    required this.status,
    required this.userFullName,
    required this.userEmail,
    this.cancelledAt,
    this.cancellationReason,
    this.durationMinutes,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);

  Map<String, dynamic> toJson() => _$ReservationToJson(this);
}
