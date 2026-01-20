import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/reservation.dart';
import '../providers/reservation_provider.dart';
import 'reservation_detail_screen.dart';

class ReservationListScreen extends StatefulWidget {
  const ReservationListScreen({Key? key}) : super(key: key);

  @override
  State<ReservationListScreen> createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen> {
  bool _isLoading = true;
  List<Reservation> _reservations = [];
  String? _selectedStatus;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final provider = context.read<ReservationProvider>();
    setState(() => _isLoading = true);

    try {
      final filter = <String, dynamic>{};

      if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
        filter['status'] = _selectedStatus;
      }

      if (_selectedDate != null) {
        filter['date'] = _selectedDate!.toIso8601String();
      }

      final result = await provider.get(filter: filter);

      setState(() {
        _reservations = result.result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reservations: $e')),
      );
    }
  }

  bool _isCancelled(String? status) {
    final s = (status ?? '').toLowerCase();
    return s == 'cancelled' || s == 'canceled';
  }

  Color _statusColor(String? status) {
    final s = (status ?? '').toLowerCase();
    if (s == 'approved' || s == 'confirmed') return Colors.green;
    if (s == 'cancelled' || s == 'canceled') return Colors.red;
    return Colors.orange;
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _isLoading = true;
      });

      _loadReservations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 216, 206),
      appBar: AppBar(
        title: const Text('Reservations'),
        backgroundColor: const Color(0xFF6F4E37),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String?>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Filter by status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: null,
                        child: Text('All statuses'),
                      ),
                      DropdownMenuItem(
                        value: 'Pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'Confirmed',
                        child: Text('Confirmed'),
                      ),
                      DropdownMenuItem(
                        value: 'Cancelled',
                        child: Text('Cancelled'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                        _isLoading = true;
                      });
                      _loadReservations();
                    },
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.date_range),
                            label: Text(
                              _selectedDate == null
                                  ? 'Search by date'
                                  : DateFormat(
                                      'dd.MM.yyyy',
                                    ).format(_selectedDate!),
                            ),
                            onPressed: _pickDate,
                          ),
                        ),
                        if (_selectedDate != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _selectedDate = null;
                                _isLoading = true;
                              });
                              _loadReservations();
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: _reservations.isEmpty
                        ? const Center(child: Text('No reservations found.'))
                        : ListView.separated(
                            itemCount: _reservations.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final r = _reservations[index];
                              final isCancelled = _isCancelled(r.status);

                              return Card(
                                color: isCancelled
                                    ? Colors.grey.shade300
                                    : const Color(0xFFCDB08F),
                                elevation: isCancelled ? 1 : 4,
                                shadowColor: Colors.black26,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: isCancelled
                                      ? BorderSide(
                                          color: Colors.red.shade300,
                                          width: 1,
                                        )
                                      : BorderSide.none,
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    isCancelled
                                        ? Icons.event_busy
                                        : Icons.event_seat,
                                    color: isCancelled
                                        ? Colors.red.shade400
                                        : const Color(0xFF6F4E37),
                                    size: 32,
                                  ),
                                  title: Text(
                                    'Table: ${r.tableNumber}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isCancelled
                                          ? Colors.grey.shade700
                                          : Colors.black,
                                      decoration: isCancelled
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        'Date: ${_formatDate(r.reservationDateTime)}',
                                        style: TextStyle(
                                          color: isCancelled
                                              ? Colors.grey.shade700
                                              : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'Guests: ${r.numberOfGuests}',
                                        style: TextStyle(
                                          color: isCancelled
                                              ? Colors.grey.shade700
                                              : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'User: ${r.userFullName ?? 'Unknown'}',
                                        style: TextStyle(
                                          color: isCancelled
                                              ? Colors.grey.shade700
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(r.status),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      r.status,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  onTap: isCancelled
                                      ? null
                                      : () async {
                                          final result =
                                              await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ReservationDetailScreen(
                                                        reservation: r,
                                                      ),
                                                ),
                                              );

                                          if (result == 'refresh') {
                                            _loadReservations();
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8B5A3C),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ReservationDetailScreen()),
          );

          if (result == 'refresh') {
            _loadReservations();
          }
        },
      ),
    );
  }
}
