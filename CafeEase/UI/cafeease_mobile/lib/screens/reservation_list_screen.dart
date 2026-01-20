import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/reservation.dart';
import '../providers/reservation_provider.dart';
import '../utils/util.dart';
import 'reservation_create_screen.dart';
import 'reservation_detail_screen.dart';

class ReservationListScreen extends StatefulWidget {
  const ReservationListScreen({super.key});

  @override
  State<ReservationListScreen> createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen> {
  bool _loading = true;
  String? _error;

  List<Reservation> _all = [];
  List<Reservation> _shown = [];

  final _searchCtrl = TextEditingController();
  String? _status;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_applyLocalSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final provider = context.read<ReservationProvider>();

      final filter = <String, dynamic>{
        "userId": Authorization.userId,
        "status": _status,
        "date": _date,
      };

      final res = await provider.get(filter: filter);

      setState(() {
        _all = res.result;
        _shown = List.from(_all);
        _loading = false;
      });

      _applyLocalSearch();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _applyLocalSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();

    setState(() {
      if (q.isEmpty) {
        _shown = List.from(_all);
        return;
      }

      _shown = _all.where((r) {
        final table = (r.tableNumber?.toString() ?? "");
        final status = (r.status ?? "").toLowerCase();
        return table.contains(q) || status.contains(q);
      }).toList();
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      initialDate: _date ?? now,
    );
    if (picked == null) return;

    setState(() => _date = DateTime(picked.year, picked.month, picked.day));
    await _load();
  }

  void _clearDate() async {
    setState(() => _date = null);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EFE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F4E37),
        title: const Text("My Reservations"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.white,
            onPressed: _load,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            color: Colors.white,
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                    builder: (_) => const CreateReservationScreen()),
              );
              if (created == true) _load();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search by table number or status...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: "Status",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text("All")),
                      DropdownMenuItem(
                          value: "Pending", child: Text("Pending")),
                      DropdownMenuItem(
                          value: "Approved", child: Text("Approved")),
                      DropdownMenuItem(
                          value: "Cancelled", child: Text("Cancelled")),
                    ],
                    onChanged: (v) async {
                      setState(() => _status = v);
                      await _load();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(_date == null
                      ? "Date"
                      : "${_date!.day}.${_date!.month}.${_date!.year}"),
                ),
                const SizedBox(width: 6),
                if (_date != null)
                  IconButton(
                    onPressed: _clearDate,
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : _shown.isEmpty
                        ? const Center(child: Text("No reservations found."))
                        : ListView.separated(
                            itemCount: _shown.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final r = _shown[i];
                              final dt = r.reservationDateTime;
                              final dateStr = dt == null
                                  ? "-"
                                  : DateFormat('dd.MM.yyyy').format(dt);
                              return ListTile(
                                title: Text(
                                    "Table: ${r.tableNumber ?? r.tableId ?? '-'}"),
                                subtitle: Text(
                                  "$dateStr • Guests: ${r.numberOfGuests ?? '-'} • ${r.status ?? ''}",
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  final changed =
                                      await Navigator.of(context).push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) => ReservationDetailsScreen(
                                          reservation: r),
                                    ),
                                  );
                                  if (changed == true) _load();
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
