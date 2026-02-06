import 'package:cafeease_desktop/models/category.dart';
import 'package:cafeease_desktop/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/promotion.dart';
import '../providers/promotion_provider.dart';

class PromotionEditScreen extends StatefulWidget {
  final Promotion? promotion;

  const PromotionEditScreen({super.key, this.promotion});

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

  final _segments = const ["ALL", "VIP", "NEW", "INACTIVE"];
  String? _selectedSegment;

  @override
  void initState() {
    super.initState();
    if (widget.promotion != null) {
      selectedCategoryIds = widget.promotion!.categories
          .map((c) => c.id!)
          .toList();
    }
    _selectedSegment = widget.promotion?.targetSegment ?? "ALL";
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

    final discount = double.tryParse(_discountController.text);

    setState(() => _isSaving = true);

    final provider = context.read<PromotionProvider>();

    final request = {
      'name': _nameController.text,
      'description': _descController.text,
      'discountPercent': discount,
      'startDate': _startDate!.toIso8601String(),
      'endDate': _endDate!.toIso8601String(),
      'categoryIds': selectedCategoryIds,
      'targetSegment': _selectedSegment,
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
                    _field(_descController, 'Description', required: false),
                    _field(
                      _discountController,
                      'Discount (%)',
                      keyboardType: TextInputType.number,
                      required: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Required field';
                        }

                        final value = double.tryParse(v);
                        if (value == null) {
                          return 'Invalid discount value';
                        }

                        if (value <= 0 || value > 100) {
                          return 'Discount must be between 1 and 100';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedSegment,
                      items: _segments
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedSegment = v ?? "ALL"),
                      decoration: InputDecoration(
                        labelText: "Target segment",
                        filled: true,
                        fillColor: Colors.brown.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    FormField<List<int>>(
                      initialValue: selectedCategoryIds,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Select at least one category';
                        }
                        return null;
                      },
                      builder: (state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                  final selected = selectedCategoryIds.contains(
                                    c.id,
                                  );
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

                                      state.didChange(
                                        List<int>.from(selectedCategoryIds),
                                      );
                                      state.validate();
                                    },
                                  );
                                }).toList(),
                              ),

                            if (state.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8, left: 4),
                                child: Text(
                                  state.errorText!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    FormField<DateTime>(
                      validator: (_) {
                        if (_startDate == null || _endDate == null) {
                          return 'Please select start and end date';
                        }
                        if (_endDate!.isBefore(_startDate!)) {
                          return 'End date must be after start date';
                        }
                        return null;
                      },
                      builder: (state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await _pickDate(true);
                                      state.didChange(_startDate);
                                    },
                                    child: Text(
                                      _startDate == null
                                          ? 'Start date'
                                          : _startDate!
                                                .toLocal()
                                                .toString()
                                                .split(' ')[0],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await _pickDate(false);
                                      state.didChange(_endDate);
                                    },
                                    child: Text(
                                      _endDate == null
                                          ? 'End date'
                                          : _endDate!
                                                .toLocal()
                                                .toString()
                                                .split(' ')[0],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (state.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8, left: 4),
                                child: Text(
                                  state.errorText!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
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
    bool required = true,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator:
            validator ??
            (required
                ? (v) => v == null || v.trim().isEmpty ? 'Required field' : null
                : null),
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
