import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  int? id;
  String? name;
  double? price;
  String? description;
  String? image;
  int? categoryId;

  Product({
    this.id,
    this.name,
    this.price,
    this.description,
    this.image,
    this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
