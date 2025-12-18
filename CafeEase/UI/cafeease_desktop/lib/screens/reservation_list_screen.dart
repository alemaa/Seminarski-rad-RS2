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

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final provider = context.read<ReservationProvider>();

    try {
      final result = await provider.get();
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
          : _reservations.isEmpty
              ? const Center(child: Text('No reservations found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reservations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final r = _reservations[index];

                    return Card(
                      color: const Color(0xFFCDB08F),
                      elevation: 4,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.event_seat,
                          color: Color(0xFF6F4E37),
                          size: 32,
                        ),
                        title: Text(
                          'Table: ${r.tableNumber}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Date: ${_formatDate(r.reservationDateTime)}'),
                            Text('Guests: ${r.numberOfGuests}'),
                            Text('UserId: ${r.userId}'),
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
                        onTap: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ReservationDetailScreen(
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8B5A3C),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ReservationDetailScreen(),
            ),
          );

          if (result == 'refresh') {
            _loadReservations();
          }
        },
      ),
    );
  }
}
