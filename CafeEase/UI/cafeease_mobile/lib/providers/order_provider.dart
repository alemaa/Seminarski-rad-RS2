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
}
