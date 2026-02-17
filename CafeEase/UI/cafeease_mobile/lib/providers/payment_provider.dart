import '../models/payment.dart';
import '../models/payment_insert_request.dart';
import 'base_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentProvider extends BaseProvider<Payment> {
  PaymentProvider() : super("api/Payments");

  @override
  Payment fromJson(data) => Payment.fromJson(data);

  Future<Payment> createPayment(PaymentInsertRequest request) async {
    final response = await insert(request.toJson());
    return response;
  }

  Future<Map<String, dynamic>> createStripeIntent(int orderId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}api/Stripe/create-intent");
    final headers = createHeaders();

    final response = await http.post(uri,
        headers: headers, body: jsonEncode({"orderId": orderId}));

        print("Stripe create-intent STATUS: ${response.statusCode}");
print("Stripe create-intent BODY: '${response.body}'");
print("CALLING URL: $uri");

    isValidResponse(response);
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Future<void> confirmStripe(int paymentId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}api/Stripe/confirm");
    final headers = createHeaders();

    final response = await http.post(uri,
        headers: headers, body: jsonEncode({"paymentId": paymentId}));
    isValidResponse(response);
  }
}
