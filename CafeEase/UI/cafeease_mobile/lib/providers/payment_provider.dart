import '../models/payment.dart';
import '../models/payment_insert_request.dart';
import 'base_provider.dart';

class PaymentProvider extends BaseProvider<Payment> {
  PaymentProvider() : super("api/Payments");

  @override
  Payment fromJson(data) => Payment.fromJson(data);

  Future<Payment> createPayment(PaymentInsertRequest request) async {
    final response = await insert(request.toJson());
    return response;
  }
}
