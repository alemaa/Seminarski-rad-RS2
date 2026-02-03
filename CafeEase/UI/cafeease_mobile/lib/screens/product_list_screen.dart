import 'dart:async';
import 'dart:convert';
import 'package:cafeease_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import 'product_detail_screen.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import '../widgets/loyalty_info_widget.dart';
import '../providers/inventory_provider.dart';
import '../models/promotion.dart';
import '../providers/loyalty_points_provider.dart';
import '../providers/promotion_provider.dart';
import '../utils/segment_utils.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  Timer? _debounce;
  final Map<int, int> _stockByProduct = {};

  bool _isLoading = true;
  bool _isSearching = false;
  List<Product> _products = [];
  List<Category> _categories = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  int? _selectedCategoryId;

  bool _loadingPromos = true;
  List<Promotion> _promos = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPromotions();
    });
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
        _loadInventoryForProducts();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPromotions() async {
    final promoProvider = context.read<PromotionProvider>();
    final loyaltyProvider = context.read<LoyaltyPointsProvider>();

    setState(() => _loadingPromos = true);

    try {
      final loyaltyRes =
          await loyaltyProvider.get(filter: {"userId": Authorization.userId});
      final points =
          loyaltyRes.result.isNotEmpty ? loyaltyRes.result.first.points : 0;

      final segment = getUserSegment(points);

      final promoRes = await promoProvider.get(filter: {
        "activeOnly": true,
        "targetSegment": segment,
      });

      setState(() {
        _promos = promoRes.result;
        _loadingPromos = false;
      });
    } catch (e) {
      setState(() => _loadingPromos = false);
    }
  }

  Future<void> _loadInventoryForProducts() async {
    final inventoryProvider = context.read<InventoryProvider>();

    final temp = <int, int>{};

    for (final p in _products) {
      final id = p.id;
      if (id == null) continue;

      try {
        temp[id] = await inventoryProvider.getStockForProduct(id);
      } catch (_) {
        temp[id] = 0;
      }
    }

    if (!mounted) return;
    setState(() {
      _stockByProduct
        ..clear()
        ..addAll(temp);
    });
  }

  Widget _buildPromotions() {
    if (_loadingPromos) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_promos.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Colors.brown.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Promotions for you",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            ..._promos.take(3).map((p) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.name ?? "",
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      "${(p.discountPercent ?? 0).toStringAsFixed(0)}%",
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
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
                  const LoyaltyInfoWidget(),
                  const SizedBox(height: 12),
                  _buildPromotions(),
                  const SizedBox(
                    height: 12,
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await _loadPromotions();
                        await _loadProducts();
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          final stock = _stockByProduct[product.id ?? -1] ?? 0;
                          final outOfStock = stock <= 0;

                          return Opacity(
                            opacity: outOfStock ? 0.45 : 1.0,
                            child: Card(
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
                                      tooltip: outOfStock
                                          ? 'Out of stock'
                                          : 'Add to cart',
                                      icon: const Icon(Icons.add_shopping_cart),
                                      onPressed: outOfStock
                                          ? null
                                          : () {
                                              final cart =
                                                  context.read<CartProvider>();
                                              final currentQty =
                                                  cart.getQuantity(product);

                                              if (currentQty >= stock) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Only $stock ${product.name} available.',
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              cart.addToCart(product);

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        '${product.name} added to cart')),
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
