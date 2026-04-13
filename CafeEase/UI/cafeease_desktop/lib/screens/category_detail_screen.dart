import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Category? category;

  const CategoryDetailScreen({super.key, this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool _saving = false;

  bool get isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(CategoryProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete category'),
        content: Text(
          'Are you sure you want to delete category "${_nameController.text.trim().isEmpty ? 'this category' : _nameController.text.trim()}"?',
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

    if (confirmed == true) {
      await _delete(provider);
    }
  }

  Future<void> _save(CategoryProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);

    setState(() => _saving = true);

    try {
      if (widget.category == null) {
        await provider.insert(
          Category(name: _nameController.text.trim()).toJson(),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category added successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await provider.update(
          widget.category!.id!,
          Category(
            id: widget.category!.id,
            name: _nameController.text.trim(),
          ).toJson(),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      navigator.pop('refresh');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete(CategoryProvider provider) async {
    await provider.delete(widget.category!.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Category deleted successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context, 'refresh');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CategoryProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFE6D4C3),
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Category' : 'Add Category'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxContentWidth = constraints.maxWidth > 900
              ? 560.0
              : constraints.maxWidth > 700
              ? 520.0
              : constraints.maxWidth;

          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Card(
                  color: const Color(0xFFF2E9E2),
                  elevation: 4,
                  shadowColor: Colors.black12,
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
                                Icons.category,
                                size: 28,
                                color: Color(0xFF6F4E37),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isEdit ? 'Category details' : 'New category',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          TextFormField(
                            controller: _nameController,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Required field'
                                : null,
                            decoration: InputDecoration(
                              labelText: 'Category name',
                              filled: true,
                              fillColor: const Color(0xFFEDE3DB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF9C6B4E),
                                  width: 1.8,
                                ),
                              ),
                            ),
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
                                    onPressed: _saving
                                        ? null
                                        : () => _confirmDelete(provider),
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
                                    backgroundColor: const Color(0xFFC9A97F),
                                    foregroundColor: const Color(0xFF4A2C2A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  onPressed: _saving
                                      ? null
                                      : () => _save(provider),
                                  child: _saving
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
                          const SizedBox(height: 4),
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
