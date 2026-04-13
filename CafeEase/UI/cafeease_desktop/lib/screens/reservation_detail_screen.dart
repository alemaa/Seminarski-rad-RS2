import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/reservation.dart';
import '../models/table.dart' as model;
import '../providers/reservation_provider.dart';
import '../providers/table_provider.dart';

class ReservationDetailScreen extends StatefulWidget {
  final Reservation? reservation;

  const ReservationDetailScreen({super.key, this.reservation});

  @override
  State<ReservationDetailScreen> createState() =>
      _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  List<model.Table> _availableTables = [];
  int? _selectedTableId;
  bool _loadingTables = true;

  late TextEditingController _guestsController;

  DateTime? _reservationDate;
  String _status = 'Pending';

  bool _isSaving = false;
  bool get isEdit => widget.reservation != null;

  String _toYmd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();

    _guestsController = TextEditingController(
      text: widget.reservation?.numberOfGuests.toString() ?? '',
    );

    _reservationDate =
        widget.reservation?.reservationDateTime ?? DateTime.now();

    _status = widget.reservation?.status ?? 'Pending';

    _loadTables();
  }

  Future<void> _loadTables() async {
    final tableProvider = context.read<TableProvider>();

    setState(() => _loadingTables = true);

    try {
      final day = _reservationDate ?? DateTime.now();
      final result = await tableProvider.get(filter: {'date': _toYmd(day)});

      if (!mounted) return;

      setState(() {
        _availableTables = result.result;
        _loadingTables = false;

        if (isEdit) {
          _selectedTableId = widget.reservation!.tableId;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingTables = false);
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reservationDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select reservation date',
      cancelText: 'Cancel',
      confirmText: 'Select',
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reservationDate ?? DateTime.now()),
      helpText: 'Select reservation time',
      cancelText: 'Cancel',
      confirmText: 'Select',
    );

    if (time == null) return;

    setState(() {
      _reservationDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });

    await _loadTables();
  }

  Future<void> _save(ReservationProvider provider) async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTableId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a table.')));
      return;
    }

    if (_reservationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select reservation date and time.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final request = {
      'tableId': _selectedTableId,
      'numberOfGuests': int.parse(_guestsController.text.trim()),
      'reservationDateTime': _reservationDate!.toIso8601String(),
      'status': _status,
    };

    try {
      if (isEdit) {
        await provider.update(widget.reservation!.id!, request);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reservation updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await provider.insert(request);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reservation added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context, 'refresh');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _delete(ReservationProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete reservation'),
        content: const Text(
          'Are you sure you want to delete this reservation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await provider.delete(widget.reservation!.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reservation deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, 'refresh');
    }
  }

  Widget _twoColumn({
    required Widget left,
    required Widget right,
    required double maxWidth,
  }) {
    final isWide = maxWidth >= 900;

    if (!isWide) {
      return Column(children: [left, const SizedBox(height: 16), right]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Required field';
        }

        if (keyboardType == TextInputType.number) {
          final parsed = int.tryParse(v.trim());
          if (parsed == null) return 'Enter a valid number';
          if (parsed <= 0) return 'Value must be greater than 0';
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.brown.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _dateTimeButton() {
    return OutlinedButton.icon(
      onPressed: _pickDateTime,
      icon: const Icon(Icons.calendar_today),
      label: Text(DateFormat('dd.MM.yyyy HH:mm').format(_reservationDate!)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        backgroundColor: Colors.brown.shade100,
        foregroundColor: const Color(0xFF5A3E36),
        side: const BorderSide(color: Colors.black26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ReservationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFE6D5C3),
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Reservation' : 'Add Reservation'),
        backgroundColor: const Color(0xFF6F4E37),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxContentWidth = constraints.maxWidth > 1200
              ? 900.0
              : constraints.maxWidth > 900
              ? 800.0
              : constraints.maxWidth;

          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Card(
                  color: Colors.brown.shade50,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.event_seat,
                                size: 30,
                                color: Color(0xFF6F4E37),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isEdit
                                    ? 'Reservation details'
                                    : 'New reservation',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          _twoColumn(
                            maxWidth: maxContentWidth,
                            left: _buildField(
                              _guestsController,
                              'Number of guests',
                              keyboardType: TextInputType.number,
                            ),
                            right: _loadingTables
                                ? Container(
                                    height: 56,
                                    alignment: Alignment.centerLeft,
                                    child: const CircularProgressIndicator(),
                                  )
                                : DropdownButtonFormField<int>(
                                    key: ValueKey(_availableTables.length),
                                    value: _selectedTableId,
                                    decoration: InputDecoration(
                                      labelText: 'Table',
                                      filled: true,
                                      fillColor: Colors.brown.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    items: _availableTables.map((table) {
                                      final isCurrentTable =
                                          table.id ==
                                          widget.reservation?.tableId;

                                      final isDisabled =
                                          (table.isOccupied ?? false) &&
                                          !isCurrentTable;

                                      return DropdownMenuItem<int>(
                                        value: table.id,
                                        enabled: !isDisabled,
                                        child: Opacity(
                                          opacity: isDisabled ? 0.4 : 1.0,
                                          child: Text(
                                            'Table ${table.number} (Capacity: ${table.capacity})',
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedTableId = value;
                                      });
                                    },
                                    validator: (value) => value == null
                                        ? 'Please select a table'
                                        : null,
                                  ),
                          ),

                          const SizedBox(height: 16),

                          _twoColumn(
                            maxWidth: maxContentWidth,
                            left: DropdownButtonFormField<String>(
                              value: _status,
                              decoration: InputDecoration(
                                labelText: 'Status',
                                filled: true,
                                fillColor: Colors.brown.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: const [
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
                                if (value != null) {
                                  setState(() => _status = value);
                                }
                              },
                            ),
                            right: _dateTimeButton(),
                          ),

                          const SizedBox(height: 28),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isEdit) ...[
                                SizedBox(
                                  width: 140,
                                  height: 48,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red.shade700,
                                      side: BorderSide(
                                        color: Colors.red.shade700,
                                        width: 1.4,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    onPressed: () => _delete(provider),
                                    child: const Text('Delete'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              SizedBox(
                                width: 150,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFC4916C),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  onPressed: _isSaving
                                      ? null
                                      : () => _save(provider),
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Save'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
