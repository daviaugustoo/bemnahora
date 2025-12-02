import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/models.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _apiService;

  ProductService(this._apiService);

  Future<List<Product>> getProducts() async {
    try {
      final response = await _apiService.get('/produto');
      Logger().d("Reponse do back: ${response.data}");

      if (response.statusCode == 200) {
        final List<dynamic> list = response.data; // <- é uma lista

        return list
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ProductException('Failed to load products');
      }
    } on DioException catch (e) {
      throw ProductException('Network error: ${e.message}');
    }
  }

  Future<Product> getProduct(String productId) async {
    try {
      final response = await _apiService.get('/produto/$productId');

      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      } else {
        throw ProductException('Product not found');
      }
    } on DioException catch (e) {
      throw ProductException('Network error: ${e.message}');
    }
  }

  Future<Product> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _apiService.post('/produto', data: productData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Product.fromJson(response.data);
      } else {
        throw ProductException('Failed to create product');
      }
    } on DioException catch (e) {
      throw ProductException('Network error: ${e.message}');
    }
  }

  Future<Product> updateProduct(
    String productId,
    Map<String, dynamic> productData,
  ) async {
    try {
      final response = await _apiService.put(
        '/produto/$productId',
        data: productData,
      );

      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      } else {
        throw ProductException('Failed to update product');
      }
    } on DioException catch (e) {
      throw ProductException('Network error: ${e.message}');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final response = await _apiService.delete('/produto/$productId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ProductException('Failed to delete product');
      }
    } on DioException catch (e) {
      throw ProductException('Network error: ${e.message}');
    }
  }
}

class ProductResponse {
  final List<Product> products;
  final List<String> categories;

  const ProductResponse({required this.products, required this.categories});

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      products: (json['products'] as List<dynamic>)
          .map((product) => Product.fromJson(product as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>)
          .map((category) => category.toString())
          .toList(),
    );
  }
}

class ProductException implements Exception {
  final String message;

  const ProductException(this.message);

  @override
  String toString() => 'ProductException: $message';
}
