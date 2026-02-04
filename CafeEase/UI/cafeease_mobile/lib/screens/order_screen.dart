import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import 'order_detail_screen.dart';
import '../utils/util.dart';
import '../providers/cart_provider.dart';
import '../providers/order_item_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/loyalty_info_widget.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = true;
  List<Order> _orders = [];

  final List<String> _statusOptions = const [
    "All",
    "Pending",
    "Paid",
    "Completed",
    "Cancelled"
  ];

  String _selectedStatus = "All";
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchOrders());
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);

    try {
      final orderProvider = context.read<OrderProvider>();

      final filter = <String, dynamic>{
        "userId": Authorization.userId,
      };

      if (_selectedStatus != "All") {
        filter["status"] = _selectedStatus;
      }

      if (_selectedDate != null) {
        filter["date"] = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      }

      final result = await orderProvider.get(filter: filter);

      setState(() {
        _orders = result.result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load orders: $e")),
      );
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked == null) return;

    setState(() => _selectedDate = picked);
    await _fetchOrders();
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = "All";
      _selectedDate = null;
    });
    _fetchOrders();
  }

  Future<void> _reorder(Order order, {bool replace = false}) async {
    final cartProvider = context.read<CartProvider>();
    final orderItemProvider = context.read<OrderItemProvider>();
    final productProvider = context.read<ProductProvider>();

    try {
      final res = await orderItemProvider.get(filter: {"orderId": order.id});
      final items = res.result;

      if (items.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("This order has no items.")),
          );
        }
        return;
      }

      if (replace) {
        cartProvider.clear();
      }

      for (final it in items) {
        final pid = it.productId;
        final qty = it.quantity ?? 1;
        if (pid == null) continue;

        final product = await productProvider.getById(pid);
        await cartProvider.addToCartWithQty(product, qty);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order added to cart.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Reorder failed. Please try again: $e")),
        );
      }
    }
  }

  Color _getStatusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'pending':
        return Icons.hourglass_top;
      case 'paid':
        return Icons.payments_outlined;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildFilters() {
    final dateLabel = _selectedDate == null
        ? "Any date"
        : DateFormat('yyyy-MM-dd').format(_selectedDate!);

    return Card(
      color: const Color(0xFFEFE1D1),
      elevation: 1,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Colors.black26)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filters",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    items: _statusOptions
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ))
                        .toList(),
                    onChanged: (val) async {
                      if (val == null) return;
                      setState(() => _selectedStatus = val);
                      await _fetchOrders();
                    },
                    decoration: InputDecoration(
                      labelText: "Status",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Date",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                        suffixIcon: _selectedDate == null
                            ? const Icon(Icons.calendar_month)
                            : IconButton(
                                tooltip: "Clear date",
                                icon: const Icon(Icons.clear),
                                onPressed: () async {
                                  setState(() => _selectedDate = null);
                                  await _fetchOrders();
                                },
                              ),
                      ),
                      child: Text(dateLabel),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.filter_alt_off),
                label: const Text("Clear filters"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_orders.isEmpty) {
      return const Center(child: Text("No orders found."));
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final o = _orders[index];
          final status = o.status ?? "Unknown";
          final color = _getStatusColor(o.status);
          final icon = _getStatusIcon(o.status);

          final dateText = (o.orderDate != null)
              ? DateFormat('yyyy-MM-dd HH:mm').format(o.orderDate!)
              : "Unknown date";

          return Card(
            color: const Color(0xFFF6EFE8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailScreen(order: o),
                  ),
                );
              },
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color),
              ),
              title: Text(
                "Order #${o.id ?? ''}",
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text("Total: ${(o.totalAmount ?? 0).toStringAsFixed(2)} KM"),
                  const SizedBox(height: 4),
                  Text("Table: ${o.tableId ?? '-'}"),
                  const SizedBox(height: 4),
                  Text(
                    "Created: $dateText",
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: color.withOpacity(0.35)),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: "Reorder",
                    icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                    onPressed: () => _reorder(o),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5A3C),
        title: const Text("Orders", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _fetchOrders,
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _buildFilters(),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: LoyaltyInfoWidget(),
          ),
          Expanded(child: _buildOrdersList()),
        ],
      ),
    );
  }
}
