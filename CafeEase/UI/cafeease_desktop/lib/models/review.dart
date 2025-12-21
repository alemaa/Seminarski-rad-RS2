import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  final int id;
  final int userId;
  final String? userFullName;
  final int productId;
  final String? productName;
  final int rating;
  final String? comment;
  final DateTime dateCreated;

  Review({
    required this.id,
    required this.userId,
    this.userFullName,
    required this.productId,
    this.productName,
    required this.rating,
    this.comment,
    required this.dateCreated,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
