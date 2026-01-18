import '../models/order_item.dart';
import 'base_provider.dart';

class OrderItemProvider extends BaseProvider<OrderItem> {
  OrderItemProvider() : super("api/OrderItems");

  @override
  OrderItem fromJson(data) => OrderItem.fromJson(data);

  Future<OrderItem> create(OrderItem request) async {
    final response = await insert(request.toJson());
    return response;
  }
}
