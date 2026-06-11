import 'order.dart';
import 'inventory.dart';
import 'order_item.dart';

class ReportData {
  final List<Order> orders;
  final List<Inventory> inventory;
  final List<OrderItem> paidOrderItems;

  ReportData({
    required this.orders,
    required this.inventory,
    required this.paidOrderItems,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      orders: (json['orders'] as List? ?? [])
          .map((x) => Order.fromJson(x))
          .toList(),
      inventory: (json['inventory'] as List? ?? [])
          .map((x) => Inventory.fromJson(x))
          .toList(),
      paidOrderItems: (json['paidOrderItems'] as List? ?? [])
          .map((x) => OrderItem.fromJson(x))
          .toList(),
    );
  }
}
