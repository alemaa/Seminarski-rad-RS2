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
  CartItem(
    this.product,
    this.count, {
    this.size,
    this.milkType,
    this.sugarLevel,
    this.note,
  });

  Product product;
  int count;

  String? size;
  String? milkType;
  int? sugarLevel;
  String? note;

  bool sameCustomization(String? s, String? m, int? sugar, String? n) {
    return size == s &&
        milkType == m &&
        sugarLevel == sugar &&
        (note ?? '') == (n ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'count': count,
      'size': size,
      'milkType': milkType,
      'sugarLevel': sugarLevel,
      'note': note,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      Product.fromJson(json['product'] as Map<String, dynamic>),
      (json['count'] as num).toInt(),
      size: json['size'] as String?,
      milkType: json['milkType'] as String?,
      sugarLevel: (json['sugarLevel'] as num?)?.toInt(),
      note: json['note'] as String?,
    );
  }
}
