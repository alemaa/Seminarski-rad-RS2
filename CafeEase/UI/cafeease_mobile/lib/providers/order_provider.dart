import '../models/order.dart';
import '../models/order_request.dart';
import 'base_provider.dart';

class OrderProvider extends BaseProvider<Order> {
  OrderProvider() : super("api/Orders");

  @override
  Order fromJson(data) => Order.fromJson(data);

  Future<Order> createOrder(OrderRequest request) async {
    final response = await insert(request.toJson());
    return response;
  }

  Future<Order> updateOrder(int id, Map<String, dynamic> request) async {
    return await update(id, request);
  }
}
