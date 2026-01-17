import 'product.dart';

class Cart {
  List<CartItem> items = [];

  Cart();

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  Cart.fromJson(Map<String, dynamic> json) {
    final list = (json['items'] as List<dynamic>? ?? []);
    items =
        list.map((x) => CartItem.fromJson(x as Map<String, dynamic>)).toList();
  }
}

class CartItem {
  CartItem(this.product, this.count);

  Product product;
  int count;

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'count': count,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      Product.fromJson(json['product'] as Map<String, dynamic>),
      (json['count'] as num).toInt(),
    );
  }
}
