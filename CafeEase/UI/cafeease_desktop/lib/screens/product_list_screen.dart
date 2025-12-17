import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';
import 'dart:convert';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final provider = context.read<ProductProvider>();

    try {
      final result = await provider.get();
      setState(() {
        _products = result.result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load products')),
      );
    }
  }

Widget _buildProductImage(String? imageBase64) {
  if (imageBase64 == null || imageBase64.isEmpty) {
    return Container(
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
  }

  try {
    return Image.memory(
      base64Decode(imageBase64),
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    );
  } catch (e) {
    return Container(
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
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF8B5A3C),
        foregroundColor: Colors.white,
        elevation: 3,
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ProductDetailScreen(),
            ),
          );

          if (result == 'refresh') {
            _loadProducts();
          }
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = _products[index];

                return Card(
                  color: const Color(0xFFCDB08F),
                  elevation: 4,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildProductImage(
                    product.image,
                  ),
                ),



                    title: Text(product.name ?? '',
                    style: TextStyle( 
                      color: Color(0xFF3E2723),
                      fontWeight: FontWeight.w600,)
                    ),
                    subtitle: Text(
                      '${product.price?.toStringAsFixed(2)} KM',
                       style: TextStyle(
                        color: Color(0xFF5D4037),
                        fontSize: 13,
                      ),
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
    );
  }
}
