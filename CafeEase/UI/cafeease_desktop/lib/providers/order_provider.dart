import '../models/order.dart';
import 'base_provider.dart';

class OrderProvider extends BaseProvider<Order> {
  OrderProvider() : super('api/Orders');

  @override
  Order fromJson(data) {
    return Order.fromJson(data);
  }
}
