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

  OrderItemRequest({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
      };
}
