import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/payment_provider.dart';
import '../models/order_request.dart';
import '../models/payment_insert_request.dart';
import '../utils/app_session.dart';
import '../widgets/select_table_dialog.dart';
import '../providers/loyalty_points_provider.dart';
import '../utils/util.dart';

enum PayType { cash, inApp }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
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

  Future<bool> _confirmSend() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm order"),
        content: const Text("Do you want to send this order?"),
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

      debugPrint("LOYALTY UPDATED UI: $points");
    } catch (e) {
      debugPrint("LOYALTY LOAD FAILED: $e");
    } finally {
      if (mounted) setState(() => _loadingLoyalty = false);
    }
  }

  String? _validateCard(String? v) {
    final s = (v ?? "").replaceAll(" ", "");
    if (s.isEmpty) return "Card number is required";
    if (s.length < 12 || s.length > 19) {
      return "Enter a valid card number (12–19 digits)";
    }
    if (!RegExp(r'^\d+$').hasMatch(s)) return "Card number must be digits only";
    return null;
  }

  String? _validateExpiry(String? v) {
    final s = (v ?? "").trim();
    if (s.isEmpty) return "Expiry is required (MM/YY)";
    if (!RegExp(r'^\d{2}\/\d{2}$').hasMatch(s)) return "Use format MM/YY";
    final mm = int.tryParse(s.substring(0, 2)) ?? 0;
    if (mm < 1 || mm > 12) return "Month must be 01–12";
    return null;
  }

  String? _validateCvv(String? v) {
    final s = (v ?? "").trim();
    if (s.isEmpty) return "CVV is required";
    if (!RegExp(r'^\d{3,4}$').hasMatch(s)) return "CVV must be 3 or 4 digits";
    return null;
  }

  String? _validateName(String? v) {
    final s = (v ?? "").trim();
    if (s.isEmpty) return "Card holder name is required";
    if (s.length < 3) return "Enter a valid name";
    return null;
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

    if (_payType == PayType.inApp) {
      final ok = _formKey.currentState?.validate() ?? false;
      if (!ok) return;
    }

    final confirmed = await _confirmSend();
    if (!confirmed) return;

    setState(() => _submitting = true);

    try {
      final items = cartProvider.items
          .map(
            (e) => OrderItemRequest(
              productId: e.product.id!,
              quantity: e.count,
            ),
          )
          .toList();

      final orderReq = OrderRequest(
        tableId: AppSession.tableId!,
        items: items,
      );

      final createdOrder = await orderProvider.createOrder(orderReq);

      if (_payType == PayType.inApp) {
        final payReq = PaymentInsertRequest(
          orderId: createdOrder.id!,
          method: "Card",
        );

        await paymentProvider.createPayment(payReq);

        await orderProvider.updateOrder(createdOrder.id!, {
          "status": "Paid",
        });
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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
          if (_payType == PayType.inApp) _cardForm(),
          const SizedBox(height: 18),
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

    final offerText = points >= 100
        ? "🎉 Offer unlocked: 10% off next order"
        : points >= 50
            ? "🎉 Offer unlocked: 5% off next order"
            : "Collect points to unlock special offers";

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
            Text(offerText,
                style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(double total) {
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
            Text("Total: ${total.toStringAsFixed(2)} KM",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            Text(
              "Table: ${AppSession.tableId ?? '-'}",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardForm() {
    return Card(
      color: Colors.brown.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Payment details",
                  style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Card holder name",
                  border: OutlineInputBorder(),
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _cardCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Card number",
                  border: OutlineInputBorder(),
                ),
                validator: _validateCard,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Expiry (MM/YY)",
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateExpiry,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvCtrl,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "CVV",
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateCvv,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
