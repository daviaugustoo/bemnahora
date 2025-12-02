import 'dart:convert';

import 'package:bem_na_hora_flutter/models/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'env.dart';

class ApiService {
  static const String _baseUrl = Env.apiBaseUrl;
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          _logger.d('Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('Response: ${response.statusCode} ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('Error: ${error.response?.statusCode} ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  Future<Response<T>> get<T>(String path) async {
    try {
      return await _dio.get<T>(path);
    } catch (e) {
      _logger.e('GET request failed: $e');
      rethrow;
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _logger.e('POST request failed: $e');
      rethrow;
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _logger.e('PUT request failed: $e');
      rethrow;
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _logger.e('DELETE request failed: $e');
      rethrow;
    }
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> removeToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<void> saveUser(String userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', userJson);
  }

  Future<void> removeUser() async {
    await _storage.delete(key: 'auth_user');
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString == null) return null;

    final Map<String, dynamic> userMap = jsonDecode(userString);
    return User.fromJson(userMap);
  }
}
