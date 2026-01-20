import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../models/inventory.dart';
import '../providers/inventory_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product? product;

  const ProductDetailScreen({Key? key, this.product}) : super(key: key);

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
      text: widget.product?.price?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );

    _loadCategories();
    if (widget.product != null) {
      _loadInventory();
    }
  }

  Future<void> _loadInventory() async {
    final inventoryProvider = context.read<InventoryProvider>();

    try {
      final result = await inventoryProvider.get(
        filter: {'productId': widget.product!.id},
      );

      if (result.result.isNotEmpty) {
        setState(() {
          _inventory = result.result.first;
          _quantity = _inventory!.quantity!;
        });
      }
    } catch (e) {}
  }

  Future<void> _loadCategories() async {
    final provider = context.read<CategoryProvider>();

    try {
      final result = await provider.get();

      setState(() {
        _categories = result.result;

        if (isEdit) {
          _selectedCategory = _categories.firstWhere(
            (c) => c.id == widget.product!.categoryId,
          );
        }

        _loadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _loadingCategories = false;
      });
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a category.")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final productProvider = context.read<ProductProvider>();
      final inventoryProvider = context.read<InventoryProvider>();

      final request = {
        "name": _nameController.text.trim(),
        "price": double.parse(_priceController.text.trim()),
        "description": _descriptionController.text.trim(),
        "image": _base64Image ?? widget.product?.image,
        "categoryId": _selectedCategory!.id,
      };

      int? productId;

      if (isEdit) {
        await productProvider.update(widget.product!.id!, request);
        productId = widget.product!.id;
      } else {
        final created = await productProvider.insert(request);
        productId = created.id;
      }

      if (productId == null) {
        throw Exception("Product ID is missing after save.");
      }

      final invRes = await inventoryProvider.get(
        filter: {"productId": productId},
      );

      final existingInv = (invRes.result.isNotEmpty)
          ? invRes.result.first
          : null;

      if (existingInv == null) {
        await inventoryProvider.insert({
          "productId": productId,
          "quantity": _quantity,
        });
      } else {
        await inventoryProvider.update(existingInv.id!, {
          "quantity": _quantity,
        });
      }

      if (!mounted) return;
      Navigator.pop(context, 'refresh');
    } catch (e, st) {
      debugPrint("ADD/EDIT PRODUCT FAILED: $e");
      debugPrint(st.toString());

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSaving = false);
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

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProductProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: Center(
        child: Card(
          color: Color(0xFFF2E9E2),
          elevation: 4,
          shadowColor: Colors.black12,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.coffee,
                      size: 48,
                      color: Color(0xFF6F4E37),
                    ),
                    const SizedBox(height: 16),

                    _buildField(_nameController, 'Name'),
                    _buildField(
                      _priceController,
                      'Price',
                      keyboardType: TextInputType.number,
                    ),
                    _buildField(_descriptionController, 'Description'),

                    const SizedBox(height: 8),

                    _loadingCategories
                        ? const CircularProgressIndicator()
                        : DropdownButtonFormField<Category>(
                            value: _selectedCategory,
                            items: _categories
                                .map(
                                  (c) => DropdownMenuItem<Category>(
                                    value: c,
                                    child: Text(c.name ?? ''),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Please select category' : null,
                            decoration: InputDecoration(
                              labelText: 'Category',
                              filled: true,
                              fillColor: Color(0xFFEDE3DB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Color(0xFF8B5A3C),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Quantity on stock',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Row(
                          children: [
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
                            Container(
                              width: 40,
                              alignment: Alignment.center,
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(fontSize: 18),
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
                      ],
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.image),
                        label: const Text('Select image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE6D4C3),
                          foregroundColor: Color(0xFF6B3E2E),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _pickImage,
                      ),
                    ),
                    if (_selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Save'),
                      ),
                    ),

                    if (isEdit) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD32F2F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete product'),
                                content: const Text(
                                  'Are you sure you want to delete this product?',
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
                              await provider.delete(widget.product!.id!);
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
          fillColor: Color(0xFFEDE3DB),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF8B5A3C)),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
