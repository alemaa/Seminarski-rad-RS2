import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';
import '../providers/category_provider.dart';
import 'dart:async';
import '../providers/inventory_provider.dart';
import '../providers/base_provider.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  Timer? _debounce;
  final Map<int, int> _stockByProduct = {};

  List<Product> _products = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  int? _selectedCategoryId;
  String _searchText = '';
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchText = value;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadProducts();
    });
  }

  Future<void> _loadCategories() async {
    final categoryProvider = context.read<CategoryProvider>();
    try {
      final result = await categoryProvider.get();
      setState(() {
        _categories = result.result;
      });
    } catch (_) {}
  }

  Future<void> _loadProducts() async {
    final provider = context.read<ProductProvider>();

    try {
      final filter = <String, dynamic>{};

      if (_searchText.trim().isNotEmpty) {
        filter['nameFTS'] = _searchText.trim();
      }

      if (_selectedCategoryId != null) {
        filter['categoryId'] = _selectedCategoryId;
      }

      final result = await provider.get(filter: filter);

      setState(() {
        _products = result.result;
        _isLoading = false;
      });

      await _loadInventoryForProducts();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadInventoryForProducts() async {
    final inventoryProvider = context.read<InventoryProvider>();

    final Map<int, int> tempStock = {};

    for (var product in _products) {
      if (product.id == null) continue;

      try {
        final result = await inventoryProvider.get(
          filter: {'productId': product.id},
        );

        tempStock[product.id!] = result.result.isNotEmpty
            ? result.result.first.quantity!
            : 0;
      } catch (_) {
        tempStock[product.id!] = 0;
      }
    }

    setState(() {
      _stockByProduct
        ..clear()
        ..addAll(tempStock);
    });
  }

  Widget _buildProductImage(String? imagePath) {
    final placeholder = Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFE6D4C3),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 28,
        color: Color(0xFF6B3E2E),
      ),
    );

    if (imagePath == null || imagePath.isEmpty) {
      return placeholder;
    }

    final imageUrl = '${BaseProvider.baseUrl}images/$imagePath';

    return Image.network(
      imageUrl,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8B5A3C),
        elevation: 8,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProductDetailScreen()),
          );

          if (result == 'refresh') {
            _loadProducts();
          }
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchText.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchText = '');
                                _loadProducts();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<int?>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All categories'),
                      ),
                      ..._categories.map((c) {
                        return DropdownMenuItem<int?>(
                          value: c.id,
                          child: Text(c.name),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedCategoryId = value);
                      _loadProducts();
                    },
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 90),
                      itemCount: _products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = _products[index];

                        return Card(
                          color: const Color(0xFFD2B48C),
                          elevation: 4,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildProductImage(product.imagePath),
                            ),
                            title: Text(
                              product.name ?? '',
                              style: const TextStyle(
                                color: Color(0xFF3E2723),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${product.price?.toStringAsFixed(2)} KM • Stock: ${_stockByProduct[product.id] ?? 0}',
                            ),

                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailScreen(product: product),
                                ),
                              );
                              if (result == 'refresh') {
                                _loadProducts();
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
