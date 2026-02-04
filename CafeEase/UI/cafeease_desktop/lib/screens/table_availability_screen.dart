import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/table.dart' as model;
import '../providers/table_provider.dart';

class TableAvailabilityScreen extends StatefulWidget {
  const TableAvailabilityScreen({super.key});

  @override
  State<TableAvailabilityScreen> createState() =>
      _TableAvailabilityScreenState();
}

class _TableAvailabilityScreenState extends State<TableAvailabilityScreen> {
  List<model.Table> _tables = [];
  bool _loading = true;

  DateTime _selectedDate = DateTime.now();
  bool? _selectedIsOccupied;
  int? _selectedMinCapacity;
  String _tableNumberQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  String _toYmd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _loadTables() async {
    final provider = context.read<TableProvider>();

    setState(() => _loading = true);

    final filter = <String, dynamic>{'date': _toYmd(_selectedDate)};

    if (_selectedIsOccupied != null) {
      filter['isOccupied'] = _selectedIsOccupied;
    }

    if (_selectedMinCapacity != null) {
      filter['capacity'] = _selectedMinCapacity;
    }

    final q = _tableNumberQuery.trim();
    if (q.isNotEmpty) {
      final parsed = int.tryParse(q);
      if (parsed != null) {
        filter['number'] = parsed;
      }
    }

    try {
      final res = await provider.get(filter: filter);

      setState(() {
        _tables = res.result;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked == null) return;

    setState(() => _selectedDate = picked);
    _loadTables();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: const Text('Table availability'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
                onPressed: _pickDate,
              ),
            ),

            const SizedBox(height: 12),

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
                      DropdownMenuItem(value: true, child: Text('Occupied')),
                    ],
                    onChanged: (v) {
                      setState(() => _selectedIsOccupied = v);
                      _loadTables();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    value: _selectedMinCapacity,
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
                    onChanged: (v) {
                      setState(() => _selectedMinCapacity = v);
                      _loadTables();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Table number',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                setState(() => _tableNumberQuery = v);
                _loadTables();
              },
            ),

            const SizedBox(height: 12),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _tables.isEmpty
                  ? const Center(child: Text('No tables found.'))
                  : ListView.builder(
                      itemCount: _tables.length,
                      itemBuilder: (context, index) {
                        final t = _tables[index];
                        final occupied = t.isOccupied == true;

                        return Card(
                          color: occupied
                              ? const Color(0xFFC4A484)
                              : const Color(0xFFD2B48C),
                          elevation: 2,
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
                              color: occupied ? Colors.red : Colors.green,
                            ),
                            title: Text(
                              'Table ${t.number}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                            subtitle: Text(
                              'Capacity: ${t.capacity} | ${occupied ? "Occupied" : "Free"}',
                              style: const TextStyle(color: Color(0xFF5D4037)),
                            ),
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
