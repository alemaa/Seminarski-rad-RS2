import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../providers/cart_provider.dart';
import '../providers/review_provider.dart';
import '../screens/add_review_screen.dart';
import '../providers/inventory_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Future<List<Review>>? _reviewsFuture;
  int _stock = 0;
  bool _loadingStock = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _loadStock();
  }

  void _loadReviews() {
    final pid = widget.product.id;
    if (pid == null) {
      _reviewsFuture = Future.value(<Review>[]);
      return;
    }

    _reviewsFuture = context
        .read<ReviewProvider>()
        .get(filter: {"productId": pid}).then((res) => res.result);
  }

  Future<void> _loadStock() async {
    final id = widget.product.id;
    if (id == null) {
      setState(() {
        _stock = 0;
        _loadingStock = false;
      });
      return;
    }

    try {
      final inv = context.read<InventoryProvider>();
      final s = await inv.getStockForProduct(id);

      if (!mounted) return;
      setState(() {
        _stock = s;
        _loadingStock = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _stock = 0;
        _loadingStock = false;
      });
    }
  }

  Widget _buildImage(String? base64Img) {
    if (base64Img == null || base64Img.isEmpty) {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE6D4C3),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined,
            size: 60, color: Color(0xFF6B3E2E)),
      );
    }

    try {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          base64Decode(base64Img),
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } catch (_) {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE6D4C3),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined,
            size: 60, color: Color(0xFF6B3E2E)),
      );
    }
  }

  double _avgRating(List<Review> reviews) {
    final rated = reviews.where((r) => r.rating != null).toList();
    if (rated.isEmpty) return 0.0;
    final sum = rated.fold<int>(0, (a, b) => a + (b.rating ?? 0));
    return sum / rated.length;
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return "";
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return "$d.$m.$y";
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final product = widget.product;

    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5A3C),
        title: Text(product.name ?? 'Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildImage(product.image),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                product.name ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${(product.price ?? 0).toStringAsFixed(2)} KM',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6F4E37),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (product.description?.trim().isNotEmpty ?? false)
                          ? product.description!.trim()
                          : 'No description.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Reviews",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<Review>>(
                      future: _reviewsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Failed to load reviews: ${snapshot.error}",
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        final reviews = snapshot.data ?? [];
                        final avg = _avgRating(reviews);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Color(0xFF8B5A3C)),
                                  const SizedBox(width: 6),
                                  Text(
                                    avg == 0
                                        ? "No rating"
                                        : avg.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF3E2723),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "(${reviews.length})",
                                    style: const TextStyle(
                                      color: Color(0xFF5D4037),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() => _loadReviews());
                                    },
                                    icon: const Icon(Icons.refresh,
                                        color: Color(0xFF8B5A3C)),
                                    label: const Text(
                                      "Refresh",
                                      style:
                                          TextStyle(color: Color(0xFF8B5A3C)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (reviews.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  "No reviews yet.",
                                  style: TextStyle(color: Color(0xFF5D4037)),
                                ),
                              )
                            else
                              ...reviews.map((r) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            r.userFullName ?? "User",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF3E2723),
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "${r.rating ?? "-"}★",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF8B5A3C),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      if (r.dateCreated != null)
                                        Text(
                                          _formatDate(r.dateCreated),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6F4E37),
                                          ),
                                        ),
                                      const SizedBox(height: 6),
                                      Text(
                                        (r.comment?.trim().isNotEmpty ?? false)
                                            ? r.comment!.trim()
                                            : "(No comment)",
                                        style: const TextStyle(
                                          color: Color(0xFF5D4037),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5A3C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _loadingStock
                      ? null
                      : () async {
                          if (_stock <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Out of stock.')),
                            );
                            return;
                          }

                          final currentQty = cart.getQuantity(product);

                          if (currentQty >= _stock) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Only $_stock ${product.name ?? "items"} available.'),
                              ),
                            );
                            return;
                          }

                          await cart.add(product);

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to cart')),
                          );
                        },
                  icon:
                      const Icon(Icons.add_shopping_cart, color: Colors.white),
                  label: const Text(
                    'Add to cart',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF8B5A3C)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    if (product.id == null) return;

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddReviewScreen(productId: product.id!),
                      ),
                    );

                    if (!mounted) return;
                    setState(() => _loadReviews());
                  },
                  icon: const Icon(Icons.star, color: Color(0xFF8B5A3C)),
                  label: const Text(
                    'Add review',
                    style: TextStyle(color: Color(0xFF8B5A3C)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
