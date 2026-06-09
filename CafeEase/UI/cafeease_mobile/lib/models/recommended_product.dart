import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'recommended_product.g.dart';

@JsonSerializable()
class RecommendedProduct {
  Product? product;
  double? score;
  String? reason;

  RecommendedProduct({
    this.product,
    this.score,
    this.reason,
  });

  factory RecommendedProduct.fromJson(Map<String, dynamic> json) =>
      _$RecommendedProductFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendedProductToJson(this);
}