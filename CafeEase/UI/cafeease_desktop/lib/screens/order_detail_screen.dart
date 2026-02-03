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

      setState(() {
        _items = result.result;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveStatus() async {
    final provider = context.read<OrderProvider>();

    setState(() => _savingStatus = true);

    try {
      await provider.update(widget.order.id!, {'status': _status});

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Status updated')));

      Navigator.pop(context, 'refresh');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _savingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: Text('Order #${widget.order.id}'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: const Color(0xFFD2B48C),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: ${DateFormat('dd.MM.yyyy HH:mm').format(widget.order.orderDate!)}',
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Total: ${widget.order.totalAmount?.toStringAsFixed(2)} KM',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            DropdownButtonFormField<String>(
                              value: _status,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Pending',
                                  child: Text('Pending'),
                                ),
                                DropdownMenuItem(
                                  value: 'Confirmed',
                                  child: Text('Confirmed'),
                                ),
                                DropdownMenuItem(
                                  value: 'Paid',
                                  child: Text('Paid'),
                                ),
                                DropdownMenuItem(
                                  value: 'Cancelled',
                                  child: Text('Cancelled'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _status = value);
                                }
                              },
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _savingStatus ? null : _saveStatus,
                                child: _savingStatus
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text('Save status'),
                              ),
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
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ..._items.map((item) {
                      final subtotal = (item.quantity! * item.price!)
                          .toDouble();

                      return Card(
                        child: ListTile(
                          title: Text(item.productName ?? ''),
                          subtitle: Text(
                            'Qty: ${item.quantity} × ${item.price?.toStringAsFixed(2)} KM',
                          ),
                          trailing: Text(
                            '${subtotal.toStringAsFixed(2)} KM',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }
}
