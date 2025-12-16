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

Widget _buildProductImage(String? imageBase64, int? categoryId) {
  if (imageBase64 == null || imageBase64.isEmpty) {
    return _categoryIcon(categoryId);
  }

  try {
    return Image.memory(
      base64Decode(imageBase64),
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    );
  } catch (e) {
    return _categoryIcon(categoryId);
  }
}

Widget _categoryIcon(int? categoryId) {
  IconData icon;
  Color color = const Color(0xFF6F4E37);

  switch (categoryId) {
    case 1: 
      icon = Icons.local_cafe;
      break;
    case 2:
      icon = Icons.local_drink;
      break;
    case 3:
      icon = Icons.cake;
      break;
    default:
      icon = Icons.fastfood;
  }

  return Icon(
    icon,
    size: 40,
    color: color,
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 208, 182, 160),
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: const Color.fromARGB(255, 160, 122, 104),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 160, 122, 104),
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
                  color: const Color.fromARGB(255, 208, 182, 160),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildProductImage(
                    product.image,
                    product.categoryId,
                  ),
                  ),



                    title: Text(product.name ?? ''),
                    subtitle: Text(
                      '${product.price?.toStringAsFixed(2)} KM',
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
