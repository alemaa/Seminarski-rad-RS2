import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../models/table.dart' as model;
import '../providers/order_provider.dart';
import 'order_detail_screen.dart';

class TableOrdersScreen extends StatefulWidget {
  final model.Table table;

  const TableOrdersScreen({super.key, required this.table});

  @override
  State<TableOrdersScreen> createState() => _TableOrdersScreenState();
}

class _TableOrdersScreenState extends State<TableOrdersScreen> {
  bool _loading = true;
  Order? _activeOrder;
  List<Order> _history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final orderProvider = context.read<OrderProvider>();
    setState(() => _loading = true);

    try {
      final activeRes = await orderProvider.get(
        filter: {'tableId': widget.table.id, 'active': true},
      );
      Order? active;
      if (activeRes.result.isNotEmpty) {
        final list = activeRes.result;

        if (list.isNotEmpty) {
          list.sort((a, b) {
            final ad = a.orderDate ?? DateTime(0);
            final bd = b.orderDate ?? DateTime(0);
            return bd.compareTo(ad);
          });

          active = list.first;
        }
      }

      final historyRes = await orderProvider.get(
        filter: {'tableId': widget.table.id},
      );

      setState(() {
        _activeOrder = active;
        _history = historyRes.result;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load orders: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFE1D1),
        appBar: AppBar(
          title: Text('Table ${widget.table.number}'),
          backgroundColor: const Color(0xFF8B5A3C),
          bottom: const TabBar(
            labelColor: Color(0xFFFFC107),
            unselectedLabelColor: Colors.white,
            indicatorColor: Color(0xFFFFC107),
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'History'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _load,
              tooltip: "Refresh",
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(children: [_buildActiveTab(), _buildHistoryTab()]),
      ),
    );
  }

  Widget _buildActiveTab() {
    if (_activeOrder == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.event_seat_outlined,
                size: 44,
                color: Color(0xFF8B5A3C),
              ),
              const SizedBox(height: 10),
              const Text(
                "No active order for this table",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 6),
              const Text("Table is currently free."),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5A3C),
                ),
                onPressed: () {
                  DefaultTabController.of(context).animateTo(1);
                },
                icon: const Icon(Icons.history, color: Colors.white),
                label: const Text(
                  "View history",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final o = _activeOrder!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: const Color(0xFFD2B48C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order #${o.id}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text("Total: ${o.totalAmount?.toStringAsFixed(2)} KM"),
                Text("Status: ${o.status}"),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5A3C),
          ),
          icon: const Icon(Icons.open_in_new, color: Colors.white),
          label: const Text(
            "Open full details",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OrderDetailScreen(order: o)),
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return const Center(child: Text("No orders in history."));
    }

    _history.sort(
      (a, b) =>
          (b.orderDate ?? DateTime(0)).compareTo(a.orderDate ?? DateTime(0)),
    );

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final o = _history[i];
        return Card(
          color: const Color(0xFFF6EFE8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            title: Text(
              "Order #${o.id ?? ''}",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              "Status: ${o.status ?? '-'} • Total: ${(o.totalAmount ?? 0).toStringAsFixed(2)} KM",
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OrderDetailScreen(order: o)),
            ),
          ),
        );
      },
    );
  }
}
