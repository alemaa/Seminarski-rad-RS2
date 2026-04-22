import 'package:json_annotation/json_annotation.dart';

part 'cafe.g.dart';

@JsonSerializable()
class Cafe {
  final int? id;
  final String? name;
  final String? address;
  final String? cityName;
  final int? cityId;
  final double? latitude;
  final double? longitude;
  final String? phoneNumber;
  final String? workingHours;
  final bool? isActive;
  final double? distanceKm;

  Cafe({
    this.id,
    this.name,
    this.address,
    this.cityName,
    this.cityId,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.workingHours,
    this.isActive,
    this.distanceKm,
  });

  factory Cafe.fromJson(Map<String, dynamic> json) => _$CafeFromJson(json);
  Map<String, dynamic> toJson() => _$CafeToJson(this);
}
