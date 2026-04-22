import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/table.dart' as model;
import '../providers/table_provider.dart';

class TableDetailScreen extends StatefulWidget {
  final model.Table? table;

  const TableDetailScreen({super.key, this.table});

  @override
  State<TableDetailScreen> createState() => _TableDetailScreenState();
}

class _TableDetailScreenState extends State<TableDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _numberController;
  late TextEditingController _capacityController;

  bool _isSaving = false;

  bool get isEdit => widget.table != null;

  @override
  void initState() {
    super.initState();

    _numberController = TextEditingController(
      text: widget.table?.number?.toString() ?? '',
    );

    _capacityController = TextEditingController(
      text: widget.table?.capacity?.toString() ?? '',
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

        if (keyboardType == TextInputType.number &&
            int.tryParse(v.trim()) == null) {
          return 'Enter valid number';
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

  Widget _twoColumn({
    required Widget left,
    required Widget right,
    required double maxWidth,
  }) {
    final isWide = maxWidth >= 700;

    if (!isWide) {
      return Column(children: [left, const SizedBox(height: 16), right]);
    }

    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  Future<void> _save(TableProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final request = {
      "number": int.parse(_numberController.text),
      "capacity": int.parse(_capacityController.text),
      "isOccupied": widget.table?.isOccupied ?? false,
    };

    try {
      if (isEdit) {
        await provider.update(widget.table!.id!, request);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Table updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await provider.insert(request);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Table added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context, 'refresh');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Operation failed')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _delete(TableProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete table'),
        content: Text(
          'Are you sure you want to delete table ${widget.table?.number}?',
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
      await provider.delete(widget.table!.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Table deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, 'refresh');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TableProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFE6D5C3),
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Table' : 'Add Table'),
        backgroundColor: const Color(0xFF6F4E37),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxContentWidth = constraints.maxWidth > 1000
              ? 800.0
              : constraints.maxWidth > 700
              ? 700.0
              : constraints.maxWidth;

          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Card(
                  elevation: 8,
                  color: const Color(0xFFD2B48C),
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
                                Icons.table_restaurant,
                                size: 28,
                                color: Color(0xFF6F4E37),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isEdit ? 'Table details' : 'New table',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          _twoColumn(
                            maxWidth: maxContentWidth,
                            left: _buildField(
                              _numberController,
                              'Table number',
                              keyboardType: TextInputType.number,
                            ),
                            right: _buildField(
                              _capacityController,
                              'Capacity',
                              keyboardType: TextInputType.number,
                            ),
                          ),

                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isEdit) ...[
                                SizedBox(
                                  width: 140,
                                  height: 44,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red.shade700,
                                      side: BorderSide(
                                        color: Colors.red.shade700,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    onPressed: () => _delete(provider),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              SizedBox(
                                width: 140,
                                height: 44,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B5A3C),
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
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Save',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
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
