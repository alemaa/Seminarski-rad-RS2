import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../screens/add_review_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

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

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

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
                child: Text(
                  (product.description?.trim().isNotEmpty ?? false)
                      ? product.description!.trim()
                      : 'No description.',
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF5D4037)),
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
                  onPressed: () async {
                    await cart.add(product);
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddReviewScreen(
                          productId: product.id!,
                        ),
                      ),
                    );
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
