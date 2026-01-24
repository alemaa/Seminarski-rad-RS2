import 'dart:convert';
import 'package:cafeease_mobile/screens/product_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../screens/payment_screen.dart';
import '../utils/app_session.dart';
import '../widgets/select_table_dialog.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartProvider _cartProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cartProvider = context.watch<CartProvider>();
  }

  @override
  Widget build(BuildContext context) {
    final items = _cartProvider.cart.items;

    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5A3C),
        title: const Text(
          "Your Cart",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: "Menu",
            icon: const Icon(Icons.view_list_rounded, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProductListScreen(),
                ),
              );
            },
          ),
          if (items.isNotEmpty)
            TextButton.icon(
              onPressed: _confirmClear,
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              label: const Text(
                "Clear",
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: items.isEmpty
          ? _buildEmpty()
          : Column(
              children: [
                Expanded(child: _buildProductCardList(items)),
                _buildBottomBar(context),
              ],
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.brown.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC7A48B)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: Color(0xFF6F4E37),
            ),
            const SizedBox(height: 12),
            const Text(
              "Your cart is empty",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text("Add some products to continue."),
            const SizedBox(height: 18),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5A3C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.view_list, color: Colors.white),
                label: const Text(
                  "Go to menu",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductListScreen(),
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

  Widget _buildProductCardList(List items) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildProductCard(item);
      },
    );
  }

  Widget _buildProductCard(dynamic item) {
    final product = item.product;
    final count = item.count as int;

    return Card(
      elevation: 3,
      color: const Color(0xFFD2B48C),
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildProductImage(product.image),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF3E2723),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${(product.price ?? 0).toStringAsFixed(2)} KM",
                    style: const TextStyle(
                      color: Color(0xFF4E342E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFC7A48B)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    color: const Color(0xFF6F4E37),
                    onPressed: () => _cartProvider.decreaseQuantity(product),
                  ),
                  Text(
                    "$count",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    color: const Color(0xFF6F4E37),
                    onPressed: () => _cartProvider.addToCart(product),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String? imageBase64) {
    final placeholder = Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC7A48B)),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFF6F4E37),
        size: 28,
      ),
    );

    if (imageBase64 == null || imageBase64.isEmpty) return placeholder;

    try {
      final bytes = base64Decode(imageBase64);
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          bytes,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
        ),
      );
    } catch (_) {
      return placeholder;
    }
  }

  Widget _buildBottomBar(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        border: const Border(
          top: BorderSide(color: Color(0xFFC7A48B)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(color: Color(0xFF6F4E37)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${_cartProvider.total.toStringAsFixed(2)} KM",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 46,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF8B5A3C)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _confirmClear,
                child: const Text(
                  "Clear",
                  style: TextStyle(color: Color(0xFF8B5A3C)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 196, 145, 108),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline,
                      color: Colors.white),
                  label: const Text(
                    "Checkout",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  onPressed: cartProvider.items.isEmpty
                      ? null
                      : () async {
                          if (AppSession.tableId == null) {
                            await showSelectTableDialog(context);
                            if (AppSession.tableId == null) return;
                          }

                          final ok = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PaymentScreen(),
                            ),
                          );

                          if (ok == true && mounted) {}
                        },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClear() {
    if (_cartProvider.cart.items.isEmpty) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Clear cart?"),
        content: const Text("This will remove all items from your cart."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5A3C),
            ),
            onPressed: () {
              Navigator.pop(context);
              _cartProvider.clear();
            },
            child: const Text("Clear", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
