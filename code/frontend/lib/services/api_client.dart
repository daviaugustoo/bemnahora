import 'package:dio/dio.dart';
import 'env.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({Dio? dio}) {
    _dio =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: Env.apiBaseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: const {'Content-Type': 'application/json'},
          ),
        );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) {
    return _dio.get<T>(path, queryParameters: query, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: query,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: query,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: query,
      options: options,
    );
  }
}
