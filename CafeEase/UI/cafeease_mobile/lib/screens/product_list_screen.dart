import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import 'product_detail_screen.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  Timer? _debounce;

  bool _isLoading = true;
  bool _isSearching = false;
  List<Product> _products = [];
  List<Category> _categories = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchText = value;

    setState(() => _isSearching = true);

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _loadProducts(isSearch: true);
      if (mounted) setState(() => _isSearching = false);
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

  Future<void> _loadProducts({bool isSearch = false}) async {
    final provider = context.read<ProductProvider>();

    if (!isSearch) {
      setState(() => _isLoading = true);
    }

    try {
      final filter = <String, dynamic>{};

      if (_searchText.trim().isNotEmpty) {
        filter['nameFTS'] = _searchText.trim();
      }

      if (_selectedCategoryId != null) {
        filter['categoryId'] = _selectedCategoryId;
      }

      final result = await provider.get(filter: filter);

      if (!mounted) return;
      setState(() {
        _products = result.result;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Widget _buildProductImage(String? imageBase64) {
    if (imageBase64 == null || imageBase64.isEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFE6D4C3),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined,
            size: 28, color: Color(0xFF6B3E2E)),
      );
    }

    try {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          base64Decode(imageBase64),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      );
    } catch (_) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFE6D4C3),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined,
            size: 28, color: Color(0xFF6B3E2E)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, __) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                ),
                if (cart.items.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cart.items.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        title: const Text('Menu'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isSearching)
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          if (_searchText.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchText = '';
                                  _isSearching = false;
                                });
                                _loadProducts(isSearch: true);
                              },
                            ),
                        ],
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int?>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
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
                          child: Text(c.name ?? ''),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedCategoryId = value);
                      _loadProducts();
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadProducts,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final product = _products[index];

                          return Card(
                            color: const Color(0xFFD2B48C),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              leading: _buildProductImage(product.image),
                              title: Text(
                                product.name ?? '',
                                style: const TextStyle(
                                  color: Color(0xFF3E2723),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '${(product.price ?? 0).toStringAsFixed(2)} KM',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Add to cart',
                                    icon: const Icon(Icons.add_shopping_cart),
                                    onPressed: () async {
                                      await context
                                          .read<CartProvider>()
                                          .addToCart(product);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                '${product.name ?? 'Product'} added to cart')),
                                      );
                                    },
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailScreen(product: product),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
