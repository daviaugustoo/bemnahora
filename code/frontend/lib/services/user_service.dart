import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/user.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  // Registrar usuário
  Future<User> register(User user) async {
    try {
      final payload = user.toCreateJson();
      // LOG do payload enviado
      // ignore: avoid_print
      print('[REGISTER] Payload: $payload');

      // O backend expõe endpoints separados por tipo: /usuario/consumidor, /usuario/entregador, /usuario/distribuidora
      final role = payload['role'] as String? ?? 'consumidor';
      final response = await _apiService.post('/usuario/$role', data: payload);

      // ignore: avoid_print
      print('[REGISTER] Status: ${response.statusCode}');
      // ignore: avoid_print
      print('[REGISTER] Body: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // O backend atualmente retorna uma mensagem de sucesso (string).
        // Como não recebemos o usuário criado, retornamos o usuário que foi enviado (com id possivelmente vazio).
        try {
          if (response.data is Map<String, dynamic>) {
            return User.fromJson(response.data as Map<String, dynamic>);
          }
        } catch (_) {}

        return user;
      } else {
        throw Exception('Falha ao registrar usuário');
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      // ignore: avoid_print
      print('[REGISTER][ERROR] Status: $status');
      // ignore: avoid_print
      print('[REGISTER][ERROR] Body: $data');
      if (status == 409) {
        throw Exception('Username já existe');
      }
      // Mensagem mais clara para 500
      if (status == 500) {
        throw Exception(
          'Erro no servidor (500): ${data is Map ? (data['message'] ?? data) : data}',
        );
      }
      throw Exception('Erro de rede: ${e.message}');
    }
  }

  // Login
  Future<AuthResponse> login(String email, String senha) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {'username': email, 'password': senha},
      );

      if (response.statusCode == 200) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data as Map<String, dynamic>;

        final authResponse = AuthResponse.fromJson(data);
        await _apiService.saveToken(authResponse.token);
        if (authResponse.user != null) {
          await _apiService.saveUser(jsonEncode(authResponse.user!.toJson()));
        }

        return authResponse;
      } else {
        throw Exception('Falha no login');
      }
    } on DioException catch (e) {
      throw Exception('Erro de rede: ${e.message}');
    }
  }

  Future<User> updateUser(User user) async {
    try {
      final response = await _apiService.put(
        '/usuario/${user.id}',
        data: user.toJson(),
      );

      if (response.statusCode == 200) {
        final updatedUser = User.fromJson(response.data);
        await _apiService.saveUser(jsonEncode(updatedUser.toJson()));
        return updatedUser;
      } else {
        throw Exception('Falha ao atualizar usuário');
      }
    } on DioException catch (e) {
      throw Exception('Erro de rede: ${e.message}');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      final response = await _apiService.delete('/usuario/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao excluir usuário');
      }
    } on DioException catch (e) {
      throw Exception('Erro de rede: ${e.message}');
    }
  }

  Future<void> logout() async {
    await _apiService.removeToken();
    await _apiService.removeUser();
  }

  Future<List<User>> getAllUsers() async {
    try {
      final response = await _apiService.get('/usuario');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao buscar usuários');
      }
    } on DioException catch (e) {
      throw Exception('Erro de rede: ${e.message}');
    }
  }

  Future<User> getUserById(String id) async {
    try {
      final response = await _apiService.get('/usuario/$id');

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Falha ao buscar usuário');
      }
    } on DioException catch (e) {
      throw Exception('Erro de rede: ${e.message}');
    } catch (e) {
      throw Exception('Erro desconhecido: $e');
    }
  }
}

class AuthResponse {
  final String token;
  final User? user;

  AuthResponse({required this.token, this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: json['usuario'] != null ? User.fromJson(json['usuario']) : null,
    );
  }
}
