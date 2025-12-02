import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  SharedPreferences? _prefs;
  String? _currentUserId;

  CartProvider() {
    _restoreLastCart();
  }

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (total, item) => total + item.quantity);

  double get totalAmount =>
      _items.fold(0.0, (total, item) => total + item.totalPrice);

  bool get isEmpty => _items.isEmpty;

  Future<void> _restoreLastCart() async {
    await _ensurePrefs();
    await _loadCart();
  }

  void attachUser(String? userId) {
    final normalized = (userId == null || userId.trim().isEmpty)
        ? null
        : userId.trim();
    if (_currentUserId == normalized && _prefs != null) return;
    _currentUserId = normalized;
    _loadCart();
  }

  String get _storageKey => 'cart_items_${_currentUserId ?? 'anon'}';

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _loadCart() async {
    await _ensurePrefs();
    final cartJson = _prefs!.getString(_storageKey);
    if (cartJson == null) {
      _items = [];
    } else {
      final List<dynamic> itemsJson = json.decode(cartJson);
      _items = itemsJson
          .map((json) => CartItem.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  Future<void> _saveCart() async {
    await _ensurePrefs();
    final itemsJson = _items.map((item) => item.toJson()).toList();
    await _prefs!.setString(_storageKey, json.encode(itemsJson));
  }

  Future<void> addItem(Product product, {int quantity = 1}) async {
    final existingIndex = _items.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      _items.add(
        CartItem(
          productId: product.id,
          productName: product.nome,
          price: product.preco,
          image: product.imagem,
          quantity: quantity,
        ),
      );
    }

    await _saveCart();
    notifyListeners();
  }

  Future<void> removeItem(String productId) async {
    _items.removeWhere((item) => item.productId == productId);
    await _saveCart();
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      await _saveCart();
      notifyListeners();
    }
  }

  Future<void> clear() async {
    _items.clear();
    await _ensurePrefs();
    await _prefs!.remove(_storageKey);
    notifyListeners();
  }

  CartItem? getItem(String productId) {
    try {
      return _items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  int getItemQuantity(String productId) {
    final item = getItem(productId);
    return item?.quantity ?? 0;
  }

  bool containsProduct(String productId) {
    return _items.any((item) => item.productId == productId);
  }
}
