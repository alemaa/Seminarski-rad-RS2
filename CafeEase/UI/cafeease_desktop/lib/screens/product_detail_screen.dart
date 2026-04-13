import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/inventory.dart';
import '../models/product.dart';
import '../providers/category_provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/product_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product? product;

  const ProductDetailScreen({super.key, this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  bool _isSaving = false;
  bool get isEdit => widget.product != null;

  File? _selectedImage;
  String? _base64Image;

  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _loadingCategories = true;

  Inventory? _inventory;
  int _quantity = 0;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: _formatPriceForInput(widget.product?.price),
    );
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );

    _loadCategories();

    if (widget.product != null) {
      _loadInventory();
    }
  }

  String _formatPriceForInput(double? value) {
    if (value == null) return '';

    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  Future<void> _loadInventory() async {
    final inventoryProvider = context.read<InventoryProvider>();

    try {
      final result = await inventoryProvider.get(
        filter: {'productId': widget.product!.id},
      );

      if (!mounted) return;

      if (result.result.isNotEmpty) {
        setState(() {
          _inventory = result.result.first;
          _quantity = _inventory!.quantity ?? 0;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load inventory')));
    }
  }

  Future<void> _loadCategories() async {
    final provider = context.read<CategoryProvider>();

    try {
      final result = await provider.get();

      if (!mounted) return;

      setState(() {
        _categories = result.result;

        if (isEdit) {
          try {
            _selectedCategory = _categories.firstWhere(
              (c) => c.id == widget.product!.categoryId,
            );
          } catch (_) {
            _selectedCategory = null;
          }
        }

        _loadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingCategories = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load categories')),
      );
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final bytes = await file.readAsBytes();

    setState(() {
      _selectedImage = file;
      _base64Image = base64Encode(bytes);
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final productProvider = context.read<ProductProvider>();
      final inventoryProvider = context.read<InventoryProvider>();

      final normalizedPrice = _priceController.text.trim().replaceAll(',', '.');

      final request = <String, dynamic>{
        'name': _nameController.text.trim(),
        'price': double.parse(normalizedPrice),
        'description': _descriptionController.text.trim(),
        'categoryId': _selectedCategory!.id,
      };

      if (_base64Image != null) {
        request['image'] = _base64Image!;
      } else if (isEdit && widget.product?.image != null) {
        request['image'] = widget.product!.image!;
      }

      int? productId;

      if (isEdit) {
        await productProvider.update(widget.product!.id!, request);
        productId = widget.product!.id;
      } else {
        final created = await productProvider.insert(request);
        productId = created.id;
      }

      if (productId == null) {
        throw Exception('Product ID is missing after save.');
      }

      final invRes = await inventoryProvider.get(
        filter: {'productId': productId},
      );

      final existingInv = invRes.result.isNotEmpty ? invRes.result.first : null;

      if (existingInv == null) {
        await inventoryProvider.insert({
          'productId': productId,
          'quantity': _quantity,
        });
      } else {
        await inventoryProvider.update(existingInv.id!, {
          'quantity': _quantity,
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Product successfully updated'
                : 'Product successfully added',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, 'refresh');
    } catch (e, st) {
      debugPrint('ADD/EDIT PRODUCT FAILED: $e');
      debugPrint(st.toString());

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

  Future<void> _delete(ProductProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete product'),
        content: Text(
          'Are you sure you want to delete "${widget.product?.name ?? "this product"}"?',
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
      await provider.delete(widget.product!.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product successfully deleted'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, 'refresh');
    }
  }

  Widget _buildField(
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
        fillColor: const Color(0xFFEDE3DB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF8B5A3C), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _quantityBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE3DB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black38),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Quantity on stock',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _quantity > 0
                ? () {
                    setState(() {
                      _quantity--;
                    });
                  }
                : null,
          ),
          SizedBox(
            width: 40,
            child: Center(
              child: Text('$_quantity', style: const TextStyle(fontSize: 18)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                _quantity++;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _imageSection() {
    Widget preview;

    if (_selectedImage != null) {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _selectedImage!,
          height: 220,
          width: double.infinity,
          fit: BoxFit.contain,
        ),
      );
    } else if (isEdit && (widget.product?.image?.isNotEmpty ?? false)) {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          base64Decode(widget.product!.image!),
          height: 220,
          width: double.infinity,
          fit: BoxFit.contain,
        ),
      );
    } else {
      preview = Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFEDE3DB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: const Center(
          child: Text(
            'No image selected',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product image',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE3DB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: preview),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 180,
            height: 46,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.image_outlined),
              label: const Text('Select image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE6D4C3),
                foregroundColor: const Color(0xFF6B3E2E),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _pickImage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProductProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxContentWidth = constraints.maxWidth > 1400
              ? 1100.0
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
                                Icons.coffee,
                                size: 30,
                                color: Color(0xFF6F4E37),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isEdit ? 'Product details' : 'New product',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          LayoutBuilder(
                            builder: (context, innerConstraints) {
                              final isWide = innerConstraints.maxWidth >= 680;

                              if (!isWide) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildField(_nameController, 'Name'),
                                    const SizedBox(height: 16),

                                    _buildField(
                                      _priceController,
                                      'Price',
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
                                        final value = double.tryParse(
                                          normalized,
                                        );

                                        if (value == null) {
                                          return 'Enter a valid number';
                                        }

                                        if (value < 0) {
                                          return 'Price cannot be negative';
                                        }

                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    _loadingCategories
                                        ? Container(
                                            height: 56,
                                            alignment: Alignment.centerLeft,
                                            child:
                                                const CircularProgressIndicator(),
                                          )
                                        : DropdownButtonFormField<Category>(
                                            value: _selectedCategory,
                                            items: _categories
                                                .map(
                                                  (c) =>
                                                      DropdownMenuItem<
                                                        Category
                                                      >(
                                                        value: c,
                                                        child: Text(
                                                          c.name ?? '',
                                                        ),
                                                      ),
                                                )
                                                .toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedCategory = value;
                                              });
                                            },
                                            validator: (value) => value == null
                                                ? 'Please select category'
                                                : null,
                                            decoration: InputDecoration(
                                              labelText: 'Category',
                                              filled: true,
                                              fillColor: const Color(
                                                0xFFEDE3DB,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFF8B5A3C),
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                    const SizedBox(height: 16),

                                    _quantityBox(),
                                    const SizedBox(height: 16),

                                    _buildField(
                                      _descriptionController,
                                      'Description',
                                      required: false,
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 16),

                                    _imageSection(),
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _buildField(_nameController, 'Name'),
                                        const SizedBox(height: 16),

                                        _buildField(
                                          _priceController,
                                          'Price',
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) {
                                              return 'Required field';
                                            }

                                            final normalized = v
                                                .trim()
                                                .replaceAll(',', '.');
                                            final value = double.tryParse(
                                              normalized,
                                            );

                                            if (value == null) {
                                              return 'Enter a valid number';
                                            }

                                            if (value < 0) {
                                              return 'Price cannot be negative';
                                            }

                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),

                                        _loadingCategories
                                            ? Container(
                                                height: 56,
                                                alignment: Alignment.centerLeft,
                                                child:
                                                    const CircularProgressIndicator(),
                                              )
                                            : DropdownButtonFormField<Category>(
                                                value: _selectedCategory,
                                                items: _categories
                                                    .map(
                                                      (c) =>
                                                          DropdownMenuItem<
                                                            Category
                                                          >(
                                                            value: c,
                                                            child: Text(
                                                              c.name ?? '',
                                                            ),
                                                          ),
                                                    )
                                                    .toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedCategory = value;
                                                  });
                                                },
                                                validator: (value) =>
                                                    value == null
                                                    ? 'Please select category'
                                                    : null,
                                                decoration: InputDecoration(
                                                  labelText: 'Category',
                                                  filled: true,
                                                  fillColor: const Color(
                                                    0xFFEDE3DB,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color: Color(
                                                                0xFF8B5A3C,
                                                              ),
                                                              width: 2,
                                                            ),
                                                      ),
                                                ),
                                              ),
                                        const SizedBox(height: 16),

                                        _quantityBox(),
                                        const SizedBox(height: 16),

                                        _buildField(
                                          _descriptionController,
                                          'Description',
                                          required: false,
                                          maxLines: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(children: [_imageSection()]),
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 24),

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
                                    backgroundColor: const Color(0xFFC9A97F),
                                    foregroundColor: const Color(0xFF4A2C2A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  onPressed: _isSaving ? null : _save,
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
