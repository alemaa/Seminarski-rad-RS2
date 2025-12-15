class Product {
  int? id;
  String? name;
  String? description;
  double? price;
  String? image;
  int? categoryId;

  Product({
    this.id,
    this.name,
    this.description,
    this.price,
    this.image,
    this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'] != null
          ? (json['price'] as num).toDouble()
          : null,
      image: json['image'],
      categoryId: json['categoryId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'categoryId': categoryId,
    };
  }
}
