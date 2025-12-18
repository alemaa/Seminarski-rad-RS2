import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/table.dart' as model;
import '../providers/table_provider.dart';

class TableDetailScreen extends StatefulWidget {
  final model.Table? table;

  const TableDetailScreen({Key? key, this.table}) : super(key: key);

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

    _numberController =
        TextEditingController(text: widget.table?.number?.toString() ?? '');
    _capacityController =
        TextEditingController(text: widget.table?.capacity?.toString() ?? '');
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
      body: Center(
        child: Card(
          elevation: 8,
          color: Colors.brown.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.table_restaurant,
                    size: 48,
                    color: Color(0xFF6F4E37),
                  ),
                  const SizedBox(height: 16),

                  _buildField(
                    _numberController,
                    'Table number',
                    keyboardType: TextInputType.number,
                  ),
                  _buildField(
                    _capacityController,
                    'Capacity',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 196, 145, 108),
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
                                "number":
                                    int.parse(_numberController.text),
                                "capacity":
                                    int.parse(_capacityController.text),
                                "isOccupied":
                                    widget.table?.isOccupied ?? false,
                              };

                              try {
                                if (isEdit) {
                                  await provider.update(
                                      widget.table!.id!, request);
                                } else {
                                  await provider.insert(request);
                                }

                                if (!mounted) return;
                                Navigator.pop(context, 'refresh');
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Operation failed')),
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
                              title: const Text('Delete table'),
                              content: const Text(
                                  'Are you sure you want to delete this table?'),
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
                            await provider.delete(widget.table!.id!);
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
