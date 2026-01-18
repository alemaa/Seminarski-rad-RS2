import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../providers/order_item_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _loading = true;
  String? _error;
  List<OrderItem> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadItems());
  }

  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final provider = context.read<OrderItemProvider>();
      final res = await provider.get(filter: {
        "orderId": widget.order.id,
      });

      setState(() {
        _items = res.result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Color _statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;

    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5A3C),
        title: Text(
          "Order #${o.id ?? ''}",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _loadItems,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeaderCard(o),
            const SizedBox(height: 12),
            _buildItemsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Order o) {
    final statusColor = _statusColor(o.status);
    final dateText = o.orderDate == null
        ? "Unknown"
        : DateFormat('yyyy-MM-dd HH:mm').format(o.orderDate!.toLocal());

    return Card(
      color: Colors.brown.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Status: ${o.status ?? '-'}",
              style: TextStyle(fontWeight: FontWeight.w800, color: statusColor),
            ),
            const SizedBox(height: 6),
            Text("Date: $dateText"),
            const SizedBox(height: 6),
            Text("Table: ${o.tableId ?? '-'}"),
            const SizedBox(height: 6),
            Text("User: ${o.userFullName ?? o.userId?.toString() ?? '-'}"),
            const Divider(height: 18),
            Text(
              "Total: ${(o.totalAmount ?? 0).toStringAsFixed(2)} KM",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Card(
        color: Colors.red.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Failed to load items",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(_error!, maxLines: 6, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _loadItems,
                  child: const Text("Retry"),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Card(
        color: Colors.brown.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Text("No items for this order."),
        ),
      );
    }

    final itemsTotal = _items.fold<double>(0, (sum, x) => sum + x.lineTotal);

    return Card(
      color: Colors.brown.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Items",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ..._items.map(_itemRow),
            const Divider(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Items total: ${itemsTotal.toStringAsFixed(2)} KM",
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemRow(OrderItem it) {
    final name = (it.productName != null && it.productName!.isNotEmpty)
        ? it.productName!
        : "Product #${it.productId ?? ''}";

    final qty = it.quantity ?? 0;
    final unitPrice = qty > 0 ? it.lineTotal / qty : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            "x$qty",
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Text(
            "${unitPrice.toStringAsFixed(2)} KM",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
