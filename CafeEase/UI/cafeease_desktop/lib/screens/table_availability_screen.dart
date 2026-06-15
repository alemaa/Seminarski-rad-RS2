import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/table.dart' as model;
import '../providers/table_provider.dart';
import '../models/reservation.dart';
import '../providers/reservation_provider.dart';

class TableAvailabilityScreen extends StatefulWidget {
  const TableAvailabilityScreen({super.key});

  @override
  State<TableAvailabilityScreen> createState() =>
      _TableAvailabilityScreenState();
}

class _TableAvailabilityScreenState extends State<TableAvailabilityScreen> {
  List<model.Table> _occupiedTables = [];
  List<model.Table> _freeTables = [];
  Map<int, List<Reservation>> _reservationsByTable = {};

  bool _loading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tableProvider = context.read<TableProvider>();
    final reservationProvider = context.read<ReservationProvider>();

    setState(() => _loading = true);

    try {
      final tablesResult = await tableProvider.get(filter: {'pageSize': 100});

      final reservationsResult = await reservationProvider.get(
        filter: {'date': _selectedDate.toIso8601String(), 'pageSize': 100},
      );

      final activeReservations = reservationsResult.result.where((reservation) {
        final status = reservation.status.toLowerCase();
        return status != 'cancelled' && status != 'canceled';
      }).toList();

      final grouped = <int, List<Reservation>>{};

      for (final reservation in activeReservations) {
        grouped.putIfAbsent(reservation.tableId, () => []).add(reservation);
      }

      for (final reservations in grouped.values) {
        reservations.sort(
          (a, b) => a.reservationDateTime.compareTo(b.reservationDateTime),
        );
      }

      final occupied = tablesResult.result.where((table) {
        return table.id != null && grouped.containsKey(table.id);
      }).toList();

      final free = tablesResult.result.where((table) {
        return table.id == null || !grouped.containsKey(table.id);
      }).toList();

      occupied.sort((a, b) => (a.number ?? 0).compareTo(b.number ?? 0));
      free.sort((a, b) => (a.number ?? 0).compareTo(b.number ?? 0));

      if (!mounted) return;

      setState(() {
        _reservationsByTable = grouped;
        _occupiedTables = occupied;
        _freeTables = free;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

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
    await _loadData();
  }

  Widget _tableCard(model.Table table, {required bool occupied}) {
    final reservations = table.id == null
        ? <Reservation>[]
        : _reservationsByTable[table.id!] ?? [];

    return Card(
      color: occupied ? const Color(0xFFC4A484) : const Color(0xFFD2B48C),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          Icons.table_restaurant,
          color: occupied ? Colors.red : Colors.green,
        ),
        title: Text(
          'Table ${table.number}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Capacity: ${table.capacity}'),

            if (!occupied)
              const Text('Free all day', style: TextStyle(color: Colors.green)),

            if (occupied)
              ...reservations.map((reservation) {
                final localStart = reservation.reservationDateTime.toLocal();

                final localEnd = localStart.add(
                  Duration(minutes: reservation.durationMinutes ?? 120),
                );

                return Text(
                  '${DateFormat('HH:mm').format(localStart)}'
                  ' - ${DateFormat('HH:mm').format(localEnd)}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: const Text('Table availability'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
                    onPressed: _pickDate,
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Reserved that day',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (_occupiedTables.isEmpty)
                  const Text('No occupied tables for this date.')
                else
                  ..._occupiedTables.map(
                    (table) => _tableCard(table, occupied: true),
                  ),

                const SizedBox(height: 24),

                const Text(
                  'Free all day',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (_freeTables.isEmpty)
                  const Text('No tables are free all day.')
                else
                  ..._freeTables.map(
                    (table) => _tableCard(table, occupied: false),
                  ),
              ],
            ),
    );
  }
}
