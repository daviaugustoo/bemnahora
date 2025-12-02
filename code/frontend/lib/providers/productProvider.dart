import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/models.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService;

  List<Product> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Filters
  String _searchQuery = '';
  String _selectedCategory = 'all';
  int _currentPage = 1;

  ProductProvider(this._productService);

  // Getters
  List<Product> get products => _products;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  int get currentPage => _currentPage;

  Future<void> loadProducts({bool reset = false}) async {
    _setLoading(true);
    _error = null;

    try {
      final List<Product> response = await _productService.getProducts();

      if (reset) {
        _products = response;
      } else {
        _products.addAll(response);
      }

      // monta categorias A PARTIR dos produtos
      _categories = _products.map((p) => p.categoria).toSet().toList();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final newProduct = await _productService.createProduct(data);
      _products.add(newProduct);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final updated = await _productService.updateProduct(id, data);

      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updated;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
    await loadProducts(reset: true);
  }

  Future<void> deleteProduct(String id) async {
    _setLoading(true);
    try {
      await _productService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      loadProducts(reset: true);
    }
  }

  void setSelectedCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _currentPage = 1;
      loadProducts(reset: true);
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _selectedCategory = 'all';
    _currentPage = 1;
    loadProducts(reset: true);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
}
