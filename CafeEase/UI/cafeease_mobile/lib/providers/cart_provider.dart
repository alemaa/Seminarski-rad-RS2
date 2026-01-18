import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  static const _storageKey = 'cafeease_cart_v1';

  List<CartItem> get items => cart.items;
  Future<void> add(Product p) => addToCart(p);

  Cart cart = Cart();

  double total = 0;

  bool _initialized = false;
  bool get initialized => _initialized;

  CartProvider() {
    init();
  }

  Future<void> init() async {
    await _loadFromStorage();
    _initialized = true;
    notifyListeners();
  }

  CartItem? findInCart(Product product) {
    return cart.items.firstWhereOrNull((item) => item.product.id == product.id);
  }

  Future<void> addToCart(Product product) async {
    final item = findInCart(product);

    if (item != null) {
      item.count++;
    } else {
      cart.items.add(CartItem(product, 1));
    }

    _calculateTotal();
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> addToCartWithQty(Product product, int qty) async {
    if (qty <= 0) return;

    final item = findInCart(product);

    if (item != null) {
      item.count += qty;
    } else {
      cart.items.add(CartItem(product, qty));
    }

    _calculateTotal();
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> decreaseQuantity(Product product) async {
    final item = findInCart(product);
    if (item == null) return;

    item.count--;
    if (item.count <= 0) {
      cart.items.remove(item);
    }

    _calculateTotal();
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> removeFromCart(Product product) async {
    cart.items.removeWhere((x) => x.product.id == product.id);
    _calculateTotal();
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> clear() async {
    cart.items.clear();
    _calculateTotal();
    notifyListeners();
    await _saveToStorage();
  }

  int getQuantity(Product product) {
    final item = findInCart(product);
    return item?.count ?? 0;
  }

  void _calculateTotal() {
    total = 0;
    for (final item in cart.items) {
      total += item.count * (item.product.price ?? 0.0);
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(cart.toJson());
    await prefs.setString(_storageKey, jsonString);
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      _calculateTotal();
      notifyListeners();
      return;
    }

    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      cart = Cart.fromJson(decoded);
      _calculateTotal();
      notifyListeners();
    } catch (_) {
      cart = Cart();
      _calculateTotal();
      notifyListeners();
      await prefs.remove(_storageKey);
    }
  }
}
