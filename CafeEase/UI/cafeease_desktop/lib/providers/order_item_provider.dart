import 'base_provider.dart';
import '../models/order_item.dart';

class OrderItemProvider extends BaseProvider<OrderItem> {
  OrderItemProvider() : super('api/OrderItems');

  @override
  OrderItem fromJson(data) {
    return OrderItem.fromJson(data);
  }
}
