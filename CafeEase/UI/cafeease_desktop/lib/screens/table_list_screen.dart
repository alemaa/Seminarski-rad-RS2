import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/table.dart' as model;
import '../providers/table_provider.dart';
import 'table_detail_screen.dart';
import 'table_orders_screen.dart';
import 'table_availability_screen.dart';

class TableListScreen extends StatefulWidget {
  const TableListScreen({super.key});

  @override
  State<TableListScreen> createState() => _TableListScreenState();
}

class _TableListScreenState extends State<TableListScreen> {
  List<model.Table> _tables = [];
  bool _loading = true;

  int? _selectedCapacity;
  final TextEditingController _tableNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  @override
  void dispose() {
    _tableNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadTables() async {
    final provider = context.read<TableProvider>();
    final filter = <String, dynamic>{};

    final numText = _tableNumberController.text.trim();
    final parsedNumber = int.tryParse(numText);
    if (parsedNumber != null) {
      filter['number'] = parsedNumber;
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
        backgroundColor: const Color(0xFF8B5A3C),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TableDetailScreen()),
          );

          if (result == 'refresh') _loadTables();
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
                        child: TextFormField(
                          controller: _tableNumberController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Table number',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _loadTables(),
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
                  Card(
                    color: const Color(0xFF8B5A3C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Check availability by date',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'See free and occupied tables for a selected day',
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TableAvailabilityScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      itemCount: _tables.length,
                      itemBuilder: (context, index) {
                        final table = _tables[index];

                        return Card(
                          color: const Color(0xFFD2B48C),
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
                            leading: const Icon(
                              Icons.table_restaurant,
                              color: Color(0xFF3E2723),
                            ),
                            title: Text(
                              'Table ${table.number}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                            subtitle: Text(
                              'Capacity: ${table.capacity}',
                              style: const TextStyle(color: Color(0xFF5D4037)),
                            ),
                            trailing: CircleAvatar(
                              backgroundColor: const Color(0xFF8B5A3C),
                              radius: 18,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.receipt_long,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                tooltip: 'Open order',
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          TableOrdersScreen(table: table),
                                    ),
                                  );
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

                              if (result == 'refresh') _loadTables();
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
