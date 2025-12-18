import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/table.dart' as model;
import '../providers/table_provider.dart';
import 'table_detail_screen.dart';

class TableListScreen extends StatefulWidget {
  const TableListScreen({super.key});

  @override
  State<TableListScreen> createState() => _TableListScreenState();
}

class _TableListScreenState extends State<TableListScreen> {
  List<model.Table> _tables = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    final provider = context.read<TableProvider>();
    final result = await provider.get();
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
          : ListView.builder(
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
                    horizontal: 16,
                    vertical: 8,
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
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF6B3E2E),
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TableDetailScreen(table: table),
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
    );
  }
}
