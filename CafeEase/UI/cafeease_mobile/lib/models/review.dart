import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  int? id;
  int? userId;
  int? productId;
  int? rating;
  String? comment;
  DateTime? dateCreated;
  String? userFullName;
  String? productName;

  Review({
    this.id,
    this.userId,
    this.productId,
    this.rating,
    this.comment,
    this.dateCreated,
    this.userFullName,
    this.productName,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
