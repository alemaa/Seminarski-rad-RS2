class OrderRequest {
  int tableId;
  List<OrderItemRequest> items;

  OrderRequest({
    required this.tableId,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'tableId': tableId,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class OrderItemRequest {
  int productId;
  int quantity;

  String? size;
  String? milkType;
  int? sugarLevel;
  String? note;

  OrderItemRequest({
    required this.productId,
    required this.quantity,
    this.size,
    this.milkType,
    this.sugarLevel,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
        'size': size,
        'milkType': milkType,
        'sugarLevel': sugarLevel,
        'note': note,
      };
}
