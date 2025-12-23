import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/table.dart' as model;
import '../providers/table_provider.dart';
import 'table_detail_screen.dart';
import '../providers/order_provider.dart';
import '../screens/order_detail_screen.dart';

class TableListScreen extends StatefulWidget {
  const TableListScreen({super.key});

  @override
  State<TableListScreen> createState() => _TableListScreenState();
}

class _TableListScreenState extends State<TableListScreen> {
  List<model.Table> _tables = [];
  bool _loading = true;
  bool? _selectedIsOccupied;
  int? _selectedCapacity;

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    final provider = context.read<TableProvider>();

    final filter = <String, dynamic>{};

    if (_selectedIsOccupied != null) {
      filter['isOccupied'] = _selectedIsOccupied;
    }

    if (_selectedCapacity != null) {
      filter['capacity'] = _selectedCapacity;
    }

    final result = await provider.get(filter: filter);

    setState(() {
      _tables = result.result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: const Text('Tables'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF8B5A3C),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TableDetailScreen()),
          );

          if (result == 'refresh') {
            _loadTables();
          }
        },
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<bool?>(
                          value: _selectedIsOccupied,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('All')),
                            DropdownMenuItem(value: false, child: Text('Free')),
                            DropdownMenuItem(
                              value: true,
                              child: Text('Occupied'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedIsOccupied = value);
                            _loadTables();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: DropdownButtonFormField<int?>(
                          value: _selectedCapacity,
                          decoration: const InputDecoration(
                            labelText: 'Min capacity',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('All')),
                            DropdownMenuItem(value: 2, child: Text('2+')),
                            DropdownMenuItem(value: 4, child: Text('4+')),
                            DropdownMenuItem(value: 6, child: Text('6+')),
                            DropdownMenuItem(value: 8, child: Text('8+')),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedCapacity = value);
                            _loadTables();
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView.builder(
                      itemCount: _tables.length,
                      itemBuilder: (context, index) {
                        final table = _tables[index];

                        return Card(
                          color: table.isOccupied == true
                              ? const Color(0xFFC4A484)
                              : const Color(0xFFD2B48C),
                          elevation: 2,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.table_restaurant,
                              color: table.isOccupied == true
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            title: Text(
                              'Table ${table.number}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                            subtitle: Text(
                              'Capacity: ${table.capacity} | '
                              '${table.isOccupied == true ? "Occupied" : "Free"}',
                              style: const TextStyle(color: Color(0xFF5D4037)),
                            ),
                            trailing: CircleAvatar(
                              backgroundColor: const Color(0xFF8B5A3C),
                              radius: 18,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.receipt_long,
                                  color: Color(0xFF6B3E2E),
                                  size: 18,
                                ),
                                tooltip: 'Open order',
                                onPressed: () async {
                                  final orderProvider = context
                                      .read<OrderProvider>();

                                  try {
                                    final result = await orderProvider.get(
                                      filter: {
                                        'tableId': table.id,
                                        'active': true,
                                      },
                                    );

                                    if (result.result.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'This table currently has no active orders.',
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }

                                    final order = result.result.first;

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            OrderDetailScreen(order: order),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Unable to load order. Please try again later.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TableDetailScreen(table: table),
                                ),
                              );

                              if (result == 'refresh') {
                                _loadTables();
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
