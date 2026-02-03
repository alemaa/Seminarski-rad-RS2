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

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CategoryProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFE6D4C3),
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: Center(
        child: Card(
          color: const Color(0xFFF2E9E2),
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFEDE3DB),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF9C6B4E),
                          width: 1.5,
                        ),
                      ),
                      labelText: 'Category name',
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC9A97F),
                        foregroundColor: Color(0xFF4A2C2A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _saving
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              final navigator = Navigator.of(context);

                              setState(() => _saving = true);

                              try {
                                if (widget.category == null) {
                                  await provider.insert(
                                    Category(
                                      name: _nameController.text,
                                    ).toJson(),
                                  );
                                } else {
                                  await provider.update(
                                    widget.category!.id!,
                                    Category(
                                      id: widget.category!.id,
                                      name: _nameController.text,
                                    ).toJson(),
                                  );
                                }

                                navigator.pop('refresh');
                              } finally {
                                setState(() => _saving = false);
                              }
                            },
                      child: const Text('Save'),
                    ),
                  ),

                  if (widget.category != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE74C3C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () async {
                          await provider.delete(widget.category!.id!);
                          Navigator.pop(context, 'refresh');
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
}
