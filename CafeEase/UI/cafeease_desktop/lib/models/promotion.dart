import 'package:json_annotation/json_annotation.dart';
import 'category.dart';

part 'promotion.g.dart';

@JsonSerializable()
class Promotion {
  final int id;
  final String name;
  final String? description;
  final double discountPercent;
  final DateTime startDate;
  final DateTime endDate;
  final List<Category> categories;
  final String? targetSegment;

  Promotion({
    required this.id,
    required this.name,
    this.description,
    required this.discountPercent,
    required this.startDate,
    required this.endDate,
    required this.categories,
    required this.targetSegment,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) =>
      _$PromotionFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionToJson(this);
}
