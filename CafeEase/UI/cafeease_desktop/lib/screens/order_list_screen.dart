import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/order_provider.dart';
import '../models/order.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final TextEditingController _orderNumberController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  Timer? _debounce;

  List<Order> _orders = [];
  bool _isLoading = false;

  String? _selectedStatus;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _orderNumberController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    final provider = context.read<OrderProvider>();

    setState(() => _isLoading = true);

    try {
      final filter = <String, dynamic>{};

      if (_selectedStatus != null) {
        filter['status'] = _selectedStatus;
      }

      if (_orderNumberController.text.isNotEmpty) {
        final id = int.tryParse(_orderNumberController.text);
        if (id != null) {
          filter['orderId'] = id;
        }
      }

      if (_userNameController.text.isNotEmpty) {
        filter['userName'] = _userNameController.text;
      }

      if (_selectedDate != null) {
        filter['date'] = _selectedDate!.toIso8601String();
      }

      final result = await provider.get(filter: filter);

      setState(() {
        _orders = result.result;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadOrders();
    }
  }

  void _clearDate() {
    setState(() => _selectedDate = null);
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _orderNumberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Order #',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _onSearchChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _userNameController,
                    decoration: const InputDecoration(
                      labelText: 'User',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _onSearchChanged(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickDate,
                    child: Text(
                      _selectedDate == null
                          ? 'Select date'
                          : DateFormat('dd.MM.yyyy').format(_selectedDate!),
                    ),
                  ),
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearDate,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String?>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                DropdownMenuItem(value: 'Confirmed', child: Text('Confirmed')),
                DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                _loadOrders();
              },
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _orders.isEmpty
                  ? const Center(child: Text('No orders found'))
                  : ListView.separated(
                      itemCount: _orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = _orders[index];

                        return Card(
                          color: const Color(0xFFD2B48C),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              'Order #${order.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date: ${DateFormat('dd.MM.yyyy HH:mm').format(order.orderDate!)}',
                                ),
                                Text('Table ID: ${order.tableId}'),
                                Text('User: ${order.userFullName ?? '-'}'),
                                Text(
                                  'Total: ${order.totalAmount?.toStringAsFixed(2)} KM',
                                ),
                                Text('Status: ${order.status}'),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OrderDetailScreen(order: order),
                                ),
                              );

                              if (result == 'refresh') {
                                _loadOrders();
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
