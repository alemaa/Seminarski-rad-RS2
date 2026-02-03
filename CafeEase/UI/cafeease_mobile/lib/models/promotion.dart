import 'package:json_annotation/json_annotation.dart';
import 'category.dart';

part 'promotion.g.dart';

@JsonSerializable(explicitToJson: true)
class Promotion {
  final int id;
  final String? name;
  final String? description;
  final double? discountPercent;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? targetSegment;
  final List<Category> categories;

  Promotion({
    required this.id,
    this.name,
    this.description,
    this.discountPercent,
    this.startDate,
    this.endDate,
    this.targetSegment,
    this.categories = const [],
  });

  factory Promotion.fromJson(Map<String, dynamic> json) =>
      _$PromotionFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionToJson(this);
}
