import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/payment_provider.dart';
import '../models/order_request.dart';
import '../utils/app_session.dart';
import '../widgets/select_table_dialog.dart';
import '../providers/loyalty_points_provider.dart';
import '../utils/util.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import '../models/payment_insert_request.dart';

enum PayType { cash, inApp }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PayType _payType = PayType.cash;

  int? _loyaltyPoints;
  bool _loadingLoyalty = false;

  final _nameCtrl = TextEditingController();
  final _cardCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLoyalty());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cardCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<bool> _confirmSend(Map<String, dynamic> preview) async {
    final subtotal = (preview["subtotal"] as num?)?.toDouble() ?? 0;
    final discountAmount = (preview["discountAmount"] as num?)?.toDouble() ?? 0;
    final totalAmount =
        (preview["totalAmount"] as num?)?.toDouble() ?? subtotal;

    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm order"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Subtotal: ${subtotal.toStringAsFixed(2)} KM"),
            Text("Discount: -${discountAmount.toStringAsFixed(2)} KM"),
            const SizedBox(height: 8),
            Text(
              "Total: ${totalAmount.toStringAsFixed(2)} KM",
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Send"),
          ),
        ],
      ),
    );

    return res == true;
  }

  Future<void> _loadLoyalty() async {
    setState(() => _loadingLoyalty = true);

    try {
      final loyaltyProvider = context.read<LoyaltyPointsProvider>();

      final res =
          await loyaltyProvider.get(filter: {"UserId": Authorization.userId});

      final points = res.result.isNotEmpty ? (res.result.first.points) : 0;
      setState(() => _loyaltyPoints = points);
    } catch (e) {
      debugPrint("LOYALTY LOAD FAILED: $e");
    } finally {
      if (mounted) setState(() => _loadingLoyalty = false);
    }
  }

  Future<void> _submit() async {
    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final paymentProvider = context.read<PaymentProvider>();

    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart is empty.")),
      );
      return;
    }

    if (AppSession.tableId == null) {
      await showSelectTableDialog(context);
      if (AppSession.tableId == null) return;
    }

    final items = cartProvider.items.map((e) {
      return OrderItemRequest(
          productId: e.product.id!,
          quantity: e.count,
          size: e.size,
          milkType: e.milkType,
          sugarLevel: e.sugarLevel,
          note: e.note);
    }).toList();

    final orderReq = OrderRequest(
      tableId: AppSession.tableId!,
      items: items,
    );

    Map<String, dynamic> preview;

    try {
      setState(() => _submitting = true);
      preview = await orderProvider.previewTotal(orderReq);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to calculate total: $e")),
      );
      return;
    } finally {
      if (mounted) setState(() => _submitting = false);
    }

    final confirmed = await _confirmSend(preview);
    if (!confirmed) return;

    setState(() => _submitting = true);

    try {
      final createdOrder = await orderProvider.createOrder(orderReq);
      if (_payType == PayType.cash) {
        await paymentProvider.createPayment(
          PaymentInsertRequest(
            orderId: createdOrder.id!,
            method: "Cash",
          ),
        );
      }
      if (_payType == PayType.inApp) {
        final res = await paymentProvider.createStripeIntent(createdOrder.id!);

        final clientSecret = res["clientSecret"];
        final paymentId = res["paymentId"];
        final publishableKey = res["publishableKey"];

        if (clientSecret == null ||
            clientSecret is! String ||
            clientSecret.isEmpty) {
          throw Exception("Missing/invalid clientSecret from backend.");
        }
        if (paymentId == null) {
          throw Exception("Missing paymentId from backend.");
        }

        if (publishableKey != null &&
            publishableKey is String &&
            publishableKey.isNotEmpty) {
          stripe.Stripe.publishableKey = publishableKey;
          await stripe.Stripe.instance.applySettings();
        }

        await stripe.Stripe.instance.initPaymentSheet(
          paymentSheetParameters: stripe.SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: "CafeEase",
          ),
        );

        await stripe.Stripe.instance.presentPaymentSheet();

        await paymentProvider.confirmStripe(paymentId as int);
      }

      await _loadLoyalty();
      await cartProvider.clear();
      AppSession.clearTable();

      if (!mounted) return;

      final msg = _payType == PayType.cash
          ? "Order placed. Please pay at the cafe."
          : "Payment successful. Order is paid.";

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      Navigator.pop(context, true);
    } on stripe.StripeException catch (e) {
      debugPrint("STRIPE ERROR: ${e.error.localizedMessage}");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.error.localizedMessage ?? "Payment cancelled"),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e, st) {
      debugPrint("ERROR: $e");
      debugPrint("STACKTRACE: $st");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5A3C),
        title: const Text("Checkout", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _summaryCard(cartProvider.total),
          const SizedBox(height: 12),
          _loyaltyCard(),
          const SizedBox(height: 12),
          _orderItemsCard(cartProvider),
          const SizedBox(height: 12),
          Card(
            color: Colors.brown.shade50,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                RadioListTile<PayType>(
                  value: PayType.cash,
                  groupValue: _payType,
                  title: const Text("Cash (pay at cafe)"),
                  onChanged:
                      _submitting ? null : (v) => setState(() => _payType = v!),
                ),
                const Divider(height: 1),
                RadioListTile<PayType>(
                  value: PayType.inApp,
                  groupValue: _payType,
                  title: const Text("Pay in app"),
                  onChanged:
                      _submitting ? null : (v) => setState(() => _payType = v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_payType == PayType.inApp) const SizedBox(height: 18),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 196, 145, 108),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.lock_outline, color: Colors.white),
              label: Text(
                _submitting ? "Processing..." : "Confirm",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loyaltyCard() {
    final points = _loyaltyPoints ?? 0;

    return Card(
      color: Colors.brown.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Loyalty program",
                style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            _loadingLoyalty
                ? const Text("Loading points...")
                : Text("Your points: $points",
                    style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(double subtotal) {
    return Card(
      color: Colors.brown.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Summary",
                style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Text("Subtotal: ${subtotal.toStringAsFixed(2)} KM",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text("Table: ${AppSession.tableId ?? '-'}",
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              "Active discounts are applied during checkout.",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderItemsCard(CartProvider cartProvider) {
    return Card(
      color: Colors.brown.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Items", style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            ...cartProvider.items.map((e) {
              final name = e.product.name ?? "";
              final qty = e.count;
              final price = (e.product.price ?? 0);
              final line = price * qty;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text("$name × $qty")),
                    Text("${line.toStringAsFixed(2)} KM"),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _submitting ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.edit),
                label: const Text("Edit cart"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
