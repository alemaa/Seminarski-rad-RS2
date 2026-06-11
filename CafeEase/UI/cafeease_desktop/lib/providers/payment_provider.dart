import '../models/payment.dart';
import 'base_provider.dart';

class PaymentProvider extends BaseProvider<Payment> {
  PaymentProvider() : super('api/Payments');

  @override
  Payment fromJson(dynamic data) => Payment.fromJson(data);

  Future<void> confirmCashPayment(int paymentId) async {
    await postCustom('api/Payments/$paymentId/confirm-cash');
  }
}
