import 'category.dart';

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

  factory Promotion.fromJson(Map<String, dynamic> json) {
    final catsJson = (json['categories'] ?? json['Categories']) as List? ?? [];

    return Promotion(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      discountPercent: (json['discountPercent'] as num?)?.toDouble(),
      startDate: _tryParseDate(json['startDate'] ?? json['StartDate']),
      endDate: _tryParseDate(json['endDate'] ?? json['EndDate']),
      targetSegment: json['targetSegment'] ?? json['TargetSegment'],
      categories: catsJson
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static DateTime? _tryParseDate(dynamic v) {
    if (v == null) return null;
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}
