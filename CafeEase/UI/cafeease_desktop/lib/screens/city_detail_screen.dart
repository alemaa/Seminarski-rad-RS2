import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/city.dart';
import '../providers/city_provider.dart';

class CityDetailScreen extends StatefulWidget {
  final City? city;

  const CityDetailScreen({super.key, this.city});

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool _saving = false;

  bool get isEdit => widget.city != null;

  @override
  void initState() {
    super.initState();
    if (widget.city != null) {
      _nameController.text = widget.city!.name ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save(CityProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final request = City(name: _nameController.text.trim()).toJson();

      if (isEdit) {
        await provider.update(widget.city!.id!, request);
      } else {
        await provider.insert(request);
      }

      if (!mounted) return;
      Navigator.pop(context, 'refresh');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(CityProvider provider) async {
    if (!isEdit) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete city'),
        content: Text('Are you sure you want to delete "${_nameController.text.trim()}"?'),
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

    if (confirmed != true) return;

    await provider.delete(widget.city!.id!);

    if (!mounted) return;
    Navigator.pop(context, 'refresh');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CityProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFE6D4C3),
      appBar: AppBar(
        title: Text(isEdit ? 'Edit City' : 'Add City'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            color: const Color(0xFFF2E9E2),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'City details' : 'New city',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Required field'
                              : null,
                      decoration: InputDecoration(
                        labelText: 'City name',
                        filled: true,
                        fillColor: const Color(0xFFEDE3DB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isEdit) ...[
                          OutlinedButton(
                            onPressed: _saving ? null : () => _delete(provider),
                            child: const Text('Delete'),
                          ),
                          const SizedBox(width: 12),
                        ],
                        ElevatedButton(
                          onPressed: _saving ? null : () => _save(provider),
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Save'),
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
  }
}
