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
      text: _formatDiscountForInput(widget.promotion?.discountPercent),
    );

    _startDate = widget.promotion?.startDate;
    _endDate = widget.promotion?.endDate;

    _loadCategories();
  }

  String _formatDate(DateTime? d) {
    if (d == null) return 'dd.MM.yyyy';

    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();

    return '$day.$month.$year';
  }

  String _formatDiscountForInput(double? value) {
    if (value == null) return '';

    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  Future<void> _loadCategories() async {
    final provider = context.read<CategoryProvider>();

    try {
      final result = await provider.get();

      if (!mounted) return;

      setState(() {
        categories = result.result;
        _loadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loadingCategories = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load categories: $e')));
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: isStart ? 'Select start date' : 'Select end date',
      cancelText: 'Cancel',
      confirmText: 'Select',
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;

          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final normalizedDiscount = _discountController.text.trim().replaceAll(
      ',',
      '.',
    );
    final discount = double.tryParse(normalizedDiscount);

    if (discount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid discount value')),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end date')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<PromotionProvider>();

    final request = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'discountPercent': discount,
      'startDate': _startDate!.toIso8601String(),
      'endDate': _endDate!.toIso8601String(),
      'categoryIds': selectedCategoryIds,
      'targetSegment': _selectedSegment,
    };

    try {
      if (widget.promotion == null) {
        await provider.insert(request);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Promotion successfully created'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await provider.update(widget.promotion!.id, request);

        if (!mounted) return;
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

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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

  Widget _dateButton({
    required String label,
    required DateTime? value,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        backgroundColor: Colors.brown.shade50,
        side: const BorderSide(color: Colors.black26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$label: ${_formatDate(value)}',
          style: const TextStyle(color: Colors.black87, fontSize: 16),
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
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
    );
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxContentWidth = constraints.maxWidth > 1400
              ? 1200.0
              : constraints.maxWidth > 1100
              ? 1000.0
              : constraints.maxWidth > 900
              ? 900.0
              : constraints.maxWidth;

          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Card(
                  color: const Color(0xFFD2B48C),
                  elevation: 6,
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
                          const Text(
                            'Promotion details',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          _twoColumn(
                            maxWidth: maxContentWidth,
                            left: _field(_nameController, 'Name'),
                            right: _field(
                              _discountController,
                              'Discount (%)',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Required field';
                                }

                                final normalized = v.trim().replaceAll(
                                  ',',
                                  '.',
                                );
                                final value = double.tryParse(normalized);

                                if (value == null) {
                                  return 'Enter a valid number';
                                }

                                if (value <= 0 || value > 100) {
                                  return 'Discount must be between 1 and 100';
                                }

                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          _field(
                            _descController,
                            'Description',
                            required: false,
                            maxLines: 2,
                          ),

                          const SizedBox(height: 16),

                          DropdownButtonFormField<String>(
                            value: _selectedSegment,
                            items: _segments
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedSegment = v ?? "ALL"),
                            decoration: InputDecoration(
                              labelText: 'Target segment',
                              filled: true,
                              fillColor: Colors.brown.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

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
                                  const Text(
                                    'Applies to categories',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (_loadingCategories)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: CircularProgressIndicator(),
                                    )
                                  else
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.brown.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.black12,
                                        ),
                                      ),
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: categories.map((c) {
                                          final selected = selectedCategoryIds
                                              .contains(c.id);

                                          return FilterChip(
                                            label: Text(c.name ?? ''),
                                            selected: selected,
                                            onSelected: (v) {
                                              if (c.id == null) return;

                                              setState(() {
                                                if (v) {
                                                  if (!selectedCategoryIds
                                                      .contains(c.id)) {
                                                    selectedCategoryIds.add(
                                                      c.id!,
                                                    );
                                                  }
                                                } else {
                                                  selectedCategoryIds.remove(
                                                    c.id!,
                                                  );
                                                }
                                              });

                                              state.didChange(
                                                List<int>.from(
                                                  selectedCategoryIds,
                                                ),
                                              );
                                              state.validate();
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  if (state.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                        left: 4,
                                      ),
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

                          const SizedBox(height: 20),

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
                                  const Text(
                                    'Promotion period',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _twoColumn(
                                    maxWidth: maxContentWidth,
                                    left: _dateButton(
                                      label: 'Start date',
                                      value: _startDate,
                                      onPressed: () async {
                                        await _pickDate(true);
                                        state.didChange(_startDate);
                                        state.validate();
                                      },
                                    ),
                                    right: _dateButton(
                                      label: 'End date',
                                      value: _endDate,
                                      onPressed: () async {
                                        await _pickDate(false);
                                        state.didChange(_endDate);
                                        state.validate();
                                      },
                                    ),
                                  ),
                                  if (state.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                        left: 4,
                                      ),
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

                          const SizedBox(height: 28),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 180,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B5A3C),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Save'),
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
