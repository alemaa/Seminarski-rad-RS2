import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../models/order_item.dart';
import '../providers/order_provider.dart';
import '../providers/order_item_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List<OrderItem> _items = [];
  bool _loading = true;
  bool _savingStatus = false;
  late String _status;
  Set<int> _expandedItems = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _status = widget.order.status ?? 'Pending';
    _loadItems();
  }

  Future<void> _loadItems() async {
    final provider = context.read<OrderItemProvider>();

    try {
      final result = await provider.get(filter: {'orderId': widget.order.id});
      for (var item in result.result) {
        print('PRODUCT: ${item.productName}');
        print('SIZE: ${item.size}');
        print('MILK: ${item.milkType}');
        print('SUGAR: ${item.sugarLevel}');
        print('NOTE: ${item.note}');
      }
      setState(() {
        _items = result.result;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<bool> _confirmStatusChange() async {
    if (_status == (widget.order.status ?? 'Pending')) {
      return true;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm status change'),
          content: Text(
            'Are you sure you want to change order #${widget.order.id} status to "$_status"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _saveStatus() async {
    final shouldContinue = await _confirmStatusChange();
    if (!shouldContinue) return;

    final provider = context.read<OrderProvider>();

    setState(() => _savingStatus = true);

    try {
      await provider.update(widget.order.id!, {'status': _status});

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Status saved')));

      Navigator.pop(context, 'refresh');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _savingStatus = false);
      }
    }
  }

  Widget _infoBlock(String label, String value, {bool bold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.brown.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 15 : 14,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
            color: const Color(0xFF3E2723),
          ),
        ),
      ],
    );
  }

  Widget buildStatusChip(String? status) {
    final s = (status ?? "").toLowerCase();

    late Color bgColor;
    late Color textColor;
    late IconData icon;
    late String label;

    switch (s) {
      case "paid":
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        label = "PAID";
        break;

      case "pending":
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.hourglass_top;
        label = "PENDING";
        break;

      case "cancelled":
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.cancel;
        label = "CANCELLED";
        break;

      case "confirmed":
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        icon = Icons.thumb_up;
        label = "CONFIRMED";
        break;

      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
        icon = Icons.help_outline;
        label = status?.toUpperCase() ?? "UNKNOWN";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF5D4037),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: const Color(0xFF3E2723),
                fontSize: bold ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOrderItemCard(OrderItem item) {
    final quantity = item.quantity ?? 0;
    final price = item.price ?? 0;
    final subtotal = quantity * price;

    final hasExtras =
        (item.size != null && item.size!.trim().isNotEmpty) ||
        (item.milkType != null && item.milkType!.trim().isNotEmpty) ||
        item.sugarLevel != null ||
        (item.note != null && item.note!.trim().isNotEmpty);

    final isExpanded = item.id != null && _expandedItems.contains(item.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: hasExtras && item.id != null
            ? () {
                setState(() {
                  if (_expandedItems.contains(item.id)) {
                    _expandedItems.remove(item.id);
                  } else {
                    _expandedItems.add(item.id!);
                  }
                });

                Future.delayed(const Duration(milliseconds: 200), () {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                });
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.productName ?? '-',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Color(0xFF3E2723),
                            ),
                          ),
                        ),
                        if (hasExtras) ...[
                          const SizedBox(width: 6),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 20,
                            color: const Color(0xFF6D4C41),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${subtotal.toStringAsFixed(2)} KM',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Qty: $quantity × ${price.toStringAsFixed(2)} KM',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),

              if (hasExtras && isExpanded) ...[
                const SizedBox(height: 10),

                if (item.size != null && item.size!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Size: ${item.size}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),

                if (item.milkType != null && item.milkType!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Milk: ${item.milkType}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),

                if (item.sugarLevel != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Sugar: ${item.sugarLevel}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),

                if (item.note != null && item.note!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Note: ${item.note}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: Text('Order #${order.id}'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: const Color(0xFFD2B48C),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order overview',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Divider(
                              color: Colors.brown.withOpacity(0.22),
                              thickness: 1,
                            ),
                            const SizedBox(height: 14),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _infoBlock(
                                        'User',
                                        (order.userFullName != null &&
                                                order.userFullName!
                                                    .trim()
                                                    .isNotEmpty)
                                            ? order.userFullName!
                                            : '-',
                                        bold: true,
                                      ),
                                      const SizedBox(height: 12),
                                      _infoBlock(
                                        'Table',
                                        order.tableNumber?.toString() ?? '-',
                                      ),
                                      const SizedBox(height: 12),
                                      _infoBlock(
                                        'Date',
                                        order.orderDate != null
                                            ? DateFormat(
                                                'dd.MM.yyyy HH:mm',
                                              ).format(order.orderDate!)
                                            : '-',
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 32),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _infoBlock(
                                        'Total',
                                        '${order.totalAmount?.toStringAsFixed(2) ?? '0.00'} KM',
                                        bold: true,
                                      ),
                                      const SizedBox(height: 12),

                                      Text(
                                        'Status',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.brown.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      buildStatusChip(order.status),

                                      const SizedBox(height: 16),

                                      Text(
                                        'Change status',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.brown.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: DropdownButtonFormField<String>(
                                              value: _status,
                                              dropdownColor: const Color(
                                                0xFFF4E6D4,
                                              ),
                                              icon: const Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                color: Color(0xFF6D4C41),
                                              ),
                                              style: const TextStyle(
                                                color: Color(0xFF3E2723),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              decoration: InputDecoration(
                                                isDense: true,
                                                filled: true,
                                                fillColor: const Color(
                                                  0xFFF4E6D4,
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 12,
                                                    ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: Color(
                                                              0xFFB08968,
                                                            ),
                                                            width: 1,
                                                          ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: Color(
                                                              0xFF8B5A3C,
                                                            ),
                                                            width: 1.4,
                                                          ),
                                                    ),
                                              ),
                                              items: const [
                                                DropdownMenuItem(
                                                  value: 'Pending',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.hourglass_top,
                                                        color: Colors.orange,
                                                        size: 16,
                                                      ),
                                                      SizedBox(width: 6),
                                                      Text('Pending'),
                                                    ],
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'Confirmed',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.thumb_up,
                                                        color: Colors.blue,
                                                        size: 16,
                                                      ),
                                                      SizedBox(width: 6),
                                                      Text('Confirmed'),
                                                    ],
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'Paid',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.check_circle,
                                                        color: Colors.green,
                                                        size: 16,
                                                      ),
                                                      SizedBox(width: 6),
                                                      Text('Paid'),
                                                    ],
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'Cancelled',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.cancel,
                                                        color: Colors.red,
                                                        size: 16,
                                                      ),
                                                      SizedBox(width: 6),
                                                      Text('Cancelled'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              onChanged: (value) {
                                                if (value != null) {
                                                  setState(
                                                    () => _status = value,
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          SizedBox(
                                            height: 46,
                                            child: ElevatedButton(
                                              onPressed: _savingStatus
                                                  ? null
                                                  : _saveStatus,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF8B5A3C,
                                                ),
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 18,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: _savingStatus
                                                  ? const SizedBox(
                                                      height: 18,
                                                      width: 18,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                    )
                                                  : const Text(
                                                      'Save',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Order items',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_items.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No order items found',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      )
                    else
                      ..._items.map(buildOrderItemCard),
                  ],
                ),
              ),
            ),
    );
  }
}
