import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/reservation.dart';
import '../providers/reservation_provider.dart';
import '../providers/table_provider.dart';
import '../models/table.dart' as model;

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

  String _toYmd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  late TextEditingController _guestsController;

  DateTime? _reservationDate;
  String _status = 'Pending';

  bool _isSaving = false;
  bool get isEdit => widget.reservation != null;

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

      setState(() {
        _availableTables = result.result;
        _loadingTables = false;

        if (isEdit) {
          _selectedTableId = widget.reservation!.tableId;
        }
      });
    } catch (e) {
      setState(() => _loadingTables = false);
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reservationDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reservationDate ?? DateTime.now()),
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
    _loadTables();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ReservationProvider>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 208, 182, 160),
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Reservation' : 'Add Reservation'),
        backgroundColor: const Color(0xFF6F4E37),
      ),
      body: Center(
        child: Card(
          color: Colors.brown.shade50,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Icon(
                      Icons.event_seat,
                      size: 48,
                      color: Color(0xFF6F4E37),
                    ),
                    const SizedBox(height: 16),

                    _buildField(
                      _guestsController,
                      'Number of guests',
                      keyboardType: TextInputType.number,
                    ),

                    _loadingTables
                        ? const CircularProgressIndicator()
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
                                  table.id == widget.reservation?.tableId;

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
                            validator: (value) =>
                                value == null ? 'Please select a table' : null,
                          ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
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
                        if (value != null) setState(() => _status = value);
                      },
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          DateFormat(
                            'dd.MM.yyyy HH:mm',
                          ).format(_reservationDate!),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _pickDateTime,
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            196,
                            145,
                            108,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isSaving
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;

                                setState(() => _isSaving = true);

                                final request = {
                                  "tableId": _selectedTableId,
                                  'numberOfGuests': int.parse(
                                    _guestsController.text,
                                  ),

                                  'reservationDateTime': _reservationDate!
                                      .toIso8601String(),
                                  'status': _status,
                                };

                                try {
                                  if (isEdit) {
                                    await provider.update(
                                      widget.reservation!.id!,
                                      request,
                                    );
                                  } else {
                                    await provider.insert(request);
                                  }

                                  if (!mounted) return;
                                  Navigator.pop(context, 'refresh');
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().replaceAll(
                                          'Exception: ',
                                          '',
                                        ),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  setState(() => _isSaving = false);
                                }
                              },
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Save'),
                      ),
                    ),

                    if (isEdit) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete reservation'),
                                content: const Text(
                                  'Are you sure you want to delete this reservation?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await provider.delete(widget.reservation!.id!);
                              if (!mounted) return;
                              Navigator.pop(context, 'refresh');
                            }
                          },
                          child: const Text('Delete'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (v) => v == null || v.isEmpty ? 'Required field' : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.brown.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
