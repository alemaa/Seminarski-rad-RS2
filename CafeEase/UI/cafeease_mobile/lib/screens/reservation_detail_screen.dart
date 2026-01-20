import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/reservation.dart';
import '../providers/reservation_provider.dart';

class ReservationDetailsScreen extends StatefulWidget {
  final Reservation reservation;
  const ReservationDetailsScreen({super.key, required this.reservation});

  @override
  State<ReservationDetailsScreen> createState() =>
      _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.reservation;

    final dt = r.reservationDateTime;
    final dateStr = dt == null ? "-" : DateFormat('dd.MM.yyyy').format(dt);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reservation details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoTile("Table", "${r.tableNumber ?? r.tableId ?? '-'}"),
            const SizedBox(height: 10),
            _infoTile("Date", dateStr),
            const SizedBox(height: 10),
            _infoTile("Guests", "${r.numberOfGuests ?? '-'}"),
            const SizedBox(height: 10),
            _infoTile("Status", "${r.status}"),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading || (r.status?.toLowerCase() == "cancelled")
                    ? null
                    : () => _cancelReservation(context, r),
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cancel),
                label: Text(
                  (r.status?.toLowerCase() == "cancelled")
                      ? "Cancelled"
                      : "Cancel reservation",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _cancelReservation(BuildContext context, Reservation r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel reservation?"),
        content:
            const Text("Are you sure you want to cancel this reservation?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes")),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _loading = true);

    try {
      final provider = context.read<ReservationProvider>();

      await provider.update(r.id!, {
        "status": "Cancelled",
        "date": r.reservationDateTime?.toIso8601String(),
        "no": r.numberOfGuests,
        "t": r.tableNumber
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reservation cancelled.")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
