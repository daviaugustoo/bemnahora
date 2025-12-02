// ignore_for_file: deprecated_member_use

import 'package:dio/dio.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {'username': email, 'password': password},
      );
      final Logger logger = Logger();
      if (response.statusCode == 200) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data as Map<String, dynamic>;

        final authResponse = AuthResponse.fromJson(data);

        logger.d(
          'Token recebidooooooooooooooooooooooooooooooooooooooooooooooo: ${authResponse.token} ,,,,,,,,,,,,,,,,,,,,,,,,, ${authResponse.user}',
        );
        await _apiService.saveToken(authResponse.token);
        await _apiService.saveUser(jsonEncode(authResponse.user!.toJson()));

        final prefs = await SharedPreferences.getInstance();
        final userSalvo = prefs.getString('user');
        logger.d("Usuário atualmente no SharedPreferences: $userSalvo");

        return authResponse;
      } else {
        throw AuthException('Login failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Invalid credentials');
      }
      throw AuthException('Network error: ${e.message}');
    }
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    required String fullName,
    UserType userType = UserType.customer,
  }) async {
    try {
      final response = await _apiService.post(
        '/signup',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'fullName': fullName,
          'userType': userType.name.toUpperCase(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(response.data);
        await _apiService.saveToken(authResponse.token);
        return authResponse;
      } else {
        throw AuthException('Registration failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw AuthException('User already exists');
      }
      throw AuthException('Network error: ${e.message}');
    }
  }

  Future<void> logout() async {
    await _apiService.removeToken();
  }

  Future<User?> getCurrentUser() async {
    try {
      final user = await _apiService.getUser();
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null;
  }
}

class AuthResponse {
  final String token;
  final User? user;

  const AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
