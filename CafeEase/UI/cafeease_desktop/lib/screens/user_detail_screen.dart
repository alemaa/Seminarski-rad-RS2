import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import 'order_detail_screen.dart';
import 'user_edit_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  bool _isLoading = true;
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final provider = context.read<OrderProvider>();

    try {
      final result = await provider.get(filter: {'userId': widget.user.id});

      setState(() {
        _orders = result.result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete user'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteUser();
    }
  }

  Future<void> _deleteUser() async {
    final provider = context.read<UserProvider>();

    try {
      await provider.delete(widget.user.id);

      if (!mounted) return;

      Navigator.pop(context, 'refresh');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: const Text('User details'),
        backgroundColor: const Color(0xFF8B5A3C),

        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserEditScreen(user: widget.user),
                ),
              );
              if (result == 'refresh') {
                navigator.pop('refresh');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: const Color(0xFFD2B48C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName ?? ''} ${user.lastName ?? ''}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (user.username != null)
                      Text('Username: ${user.username}'),
                    if (user.email != null) Text('Email: ${user.email}'),
                    Text('Role ID: ${user.roleId}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _orders.isEmpty
                  ? const Center(child: Text('This user has no orders'))
                  : ListView.separated(
                      itemCount: _orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, index) {
                        final order = _orders[index];

                        return Card(
                          color: const Color(0xFFCDB08F),
                          child: ListTile(
                            title: Text('Order #${order.id}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date: ${_formatDate(order.orderDate)}'),
                                Text(
                                  'Total: ${order.totalAmount?.toStringAsFixed(2)} KM',
                                ),
                                Text('Status: ${order.status}'),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OrderDetailScreen(order: order),
                                ),
                              );
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
