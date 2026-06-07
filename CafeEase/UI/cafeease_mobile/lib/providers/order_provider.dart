import '../models/order.dart';
import '../models/order_request.dart';
import 'base_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  Future<Map<String, dynamic>> previewTotal(OrderRequest request) async {
    final uri = Uri.parse('${BaseProvider.baseUrl}api/Orders/preview-total');

    final response = await http.post(
      uri,
      headers: createHeaders(),
      body: jsonEncode(request.toJson()),
    );

    isValidResponse(response);

    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }
}
