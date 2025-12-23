import 'package:cafeease_desktop/models/category.dart';
import 'package:cafeease_desktop/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/promotion.dart';
import '../providers/promotion_provider.dart';

class PromotionEditScreen extends StatefulWidget {
  final Promotion? promotion;

  const PromotionEditScreen({Key? key, this.promotion}) : super(key: key);

  @override
  State<PromotionEditScreen> createState() => _PromotionEditScreenState();
}

class _PromotionEditScreenState extends State<PromotionEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _discountController;

  DateTime? _startDate;
  DateTime? _endDate;

  List<Category> categories = [];
  List<int> selectedCategoryIds = [];

  bool _loadingCategories = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.promotion != null) {
      selectedCategoryIds = widget.promotion!.categories
          .map((c) => c.id!)
          .toList();
    }
    _nameController = TextEditingController(text: widget.promotion?.name ?? '');
    _descController = TextEditingController(
      text: widget.promotion?.description ?? '',
    );
    _discountController = TextEditingController(
      text: widget.promotion?.discountPercent.toString() ?? '',
    );

    _startDate = widget.promotion?.startDate;
    _endDate = widget.promotion?.endDate;

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final provider = context.read<CategoryProvider>();
    final result = await provider.get();

    setState(() {
      categories = result.result;
      _loadingCategories = false;
    });
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        isStart ? _startDate = picked : _endDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select start and end date')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    if (selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one category')),
      );
      return;
    }

    final discount = double.tryParse(_discountController.text);
    if (discount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid discount value')));
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<PromotionProvider>();

    final request = {
      'id': widget.promotion!.id,
      'name': _nameController.text,
      'description': _descController.text,
      'discountPercent': discount,
      'startDate': _startDate!.toIso8601String(),
      'endDate': _endDate!.toIso8601String(),
      'categoryIds': selectedCategoryIds,
    };

    try {
      if (widget.promotion == null) {
        await provider.insert(request);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Promotion successfully created'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await provider.update(widget.promotion!.id, request);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Promotion successfully updated'),
            backgroundColor: Colors.green,
          ),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, 'refresh');
    } catch (e) {
      debugPrint('UPDATE PROMOTION ERROR: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: Text(
          widget.promotion == null ? 'Add promotion' : 'Edit promotion',
        ),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: Center(
        child: Card(
          color: const Color(0xFFD2B48C),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _field(_nameController, 'Name'),
                    _field(_descController, 'Description'),
                    _field(
                      _discountController,
                      'Discount (%)',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Applies to categories',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_loadingCategories)
                      const CircularProgressIndicator()
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: categories.map((c) {
                          final selected = selectedCategoryIds.contains(c.id);
                          return FilterChip(
                            label: Text(c.name ?? ''),
                            selected: selected,
                            onSelected: (v) {
                              if (c.id == null) return;
                              setState(() {
                                v
                                    ? selectedCategoryIds.add(c.id!)
                                    : selectedCategoryIds.remove(c.id!);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _pickDate(true),
                            child: Text(
                              _startDate == null
                                  ? 'Start date'
                                  : _startDate!.toLocal().toString().split(
                                      ' ',
                                    )[0],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _pickDate(false),
                            child: Text(
                              _endDate == null
                                  ? 'End date'
                                  : _endDate!.toLocal().toString().split(
                                      ' ',
                                    )[0],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Save'),
                      ),
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

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (v) =>
            v == null || v.trim().isEmpty ? 'Required field' : null,
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
