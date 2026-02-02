import 'package:json_annotation/json_annotation.dart';

part 'loyalty_points.g.dart';

@JsonSerializable()
class LoyaltyPoints {
  final int id;
  final int userId;
  final int points;

  LoyaltyPoints({
    required this.id,
    required this.userId,
    required this.points,
  });

  factory LoyaltyPoints.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyPointsFromJson(json);

  Map<String, dynamic> toJson() => _$LoyaltyPointsToJson(this);
}
