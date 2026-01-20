import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/table.dart' as m;
import '../providers/reservation_provider.dart';
import '../providers/table_provider.dart';

class CreateReservationScreen extends StatefulWidget {
  const CreateReservationScreen({super.key});

  @override
  State<CreateReservationScreen> createState() =>
      _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  DateTime? _selectedDate;
  m.Table? _selectedTable;
  final _guestsCtrl = TextEditingController();

  bool _dateError = false;
  bool _tableError = false;
  bool _guestsError = false;
  bool _tableNeedsDateMsg = false;

  bool _loading = false;
  String? _error;

  List<m.Table> _tables = [];
  Set<int> _occupiedTableIds = {};

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  @override
  void dispose() {
    _guestsCtrl.dispose();
    super.dispose();
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _loadTables() async {
    final tableProvider = context.read<TableProvider>();
    final res = await tableProvider.get();
    if (!mounted) return;
    setState(() => _tables = res.result);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;

    final selected = DateTime(date.year, date.month, date.day);

    setState(() {
      _selectedDate = selected;
      _dateError = false;

      _selectedTable = null;
      _occupiedTableIds = {};

      _error = null;
      _tableError = false;
      _tableNeedsDateMsg = false;
    });

    await _loadOccupiedForDate(selected);
  }

  Future<void> _loadOccupiedForDate(DateTime date) async {
    final reservationProvider = context.read<ReservationProvider>();
    try {
      final list = await reservationProvider.getForDate(date);

      final occupied = list
          .where((r) => r.tableId != null && r.status != "Cancelled")
          .map((r) => r.tableId!)
          .toSet();

      if (!mounted) return;
      setState(() => _occupiedTableIds = occupied);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final guests = int.tryParse(_guestsCtrl.text.trim());
    if (_tableNeedsDateMsg) {
      setState(() => _tableNeedsDateMsg = false);
    }

    if (_selectedDate == null &&
        _selectedTable == null &&
        (guests == null || guests <= 0)) {
      _showMsg("Please fill in all required fields.");
      setState(() {
        _dateError = true;
        _tableError = true;
        _guestsError = true;
        _tableNeedsDateMsg = false;
      });
      return;
    }

    if (_selectedDate == null) {
      _showMsg("Please select a reservation date.");
      setState(() {
        _dateError = true;
        _tableNeedsDateMsg = false;
      });
      return;
    }

    if (_selectedTable == null) {
      _showMsg("Please select a table.");
      setState(() {
        _tableError = true;
        _tableNeedsDateMsg = false;
      });
      return;
    }

    if (guests == null || guests <= 0) {
      _showMsg("Please enter a valid number of guests.");
      setState(() => _guestsError = true);
      return;
    }

    final cap = _selectedTable!.capacity ?? 0;
    if (cap > 0 && guests > cap) {
      _showMsg("Table capacity is $cap guests.");
      return;
    }

    if (_selectedTable!.id != null &&
        _occupiedTableIds.contains(_selectedTable!.id)) {
      _showMsg("This table is already occupied on the selected date.");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final reservationProvider = context.read<ReservationProvider>();

      await reservationProvider.insert({
        "tableId": _selectedTable!.id,
        "reservationDateTime": _selectedDate!.toIso8601String(),
        "numberOfGuests": guests,
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showMsg(e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate == null
        ? "Select reservation date"
        : "${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}";

    return Scaffold(
      backgroundColor: const Color(0xFFF6EFE8),
      appBar: AppBar(
        title: const Text("New reservation"),
        backgroundColor: const Color(0xFF6F4E37),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _dateError ? Colors.red : Colors.grey,
                  ),
                ),
                onPressed: _loading ? null : _pickDate,
                child: Text(
                  dateText,
                  style: TextStyle(
                    color: _dateError ? Colors.red : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                if (_selectedDate == null) {
                  setState(() {
                    _tableError = true;
                    _dateError = true;
                    _tableNeedsDateMsg = true;
                  });
                  _showMsg("Please select a date first.");
                }
              },
              child: AbsorbPointer(
                absorbing: _selectedDate == null,
                child: DropdownButtonFormField<m.Table>(
                  value: _selectedTable,
                  decoration: InputDecoration(
                    labelText: "Table (No. & Capacity)",
                    border: const OutlineInputBorder(),
                    errorText: _tableNeedsDateMsg
                        ? "Please select a date first before choosing a table."
                        : (_tableError ? "" : null),
                  ),
                  items: _tables.map((t) {
                    final isOcc =
                        t.id != null && _occupiedTableIds.contains(t.id);
                    final label = "Table ${t.number} (${t.capacity})";

                    return DropdownMenuItem<m.Table>(
                      value: t,
                      child: Opacity(
                        opacity: isOcc ? 0.4 : 1.0,
                        child: Text(isOcc ? "$label • occupied" : label),
                      ),
                    );
                  }).toList(),
                  onChanged: (_loading || _selectedDate == null)
                      ? null
                      : (val) {
                          if (val?.id == null) return;

                          if (_occupiedTableIds.contains(val!.id)) {
                            _showMsg(
                                "This table is already booked for that date.");
                            return;
                          }

                          setState(() {
                            _selectedTable = val;
                            _tableError = false;
                            _tableNeedsDateMsg = false;
                          });
                        },
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _guestsCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Number of guests",
                border: const OutlineInputBorder(),
                errorText: _guestsError ? "" : null,
              ),
              onChanged: (_) {
                if (_guestsError) {
                  setState(() => _guestsError = false);
                }
              },
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Make a reservation"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
