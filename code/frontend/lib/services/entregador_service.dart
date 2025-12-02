import 'package:dio/dio.dart';

import 'api_service.dart';

class EntregadorService {
  final ApiService _api;
  EntregadorService(this._api);

  Future<List<Map<String, dynamic>>> getAll() async {
    final Response res = await _api.get('/Usuario');
    if (res.statusCode == 200) {
      final data = (res.data as List?) ?? const <dynamic>[];
      return data.map((item) => (item as Map).cast<String, dynamic>()).where((
        map,
      ) {
        final role = (map['tipoUsuario'] ?? map['role'] ?? map['tipo'] ?? '')
            .toString()
            .toLowerCase();
        return role.contains('entregador');
      }).toList();
    }
    throw Exception('Erro ao listar entregadores: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final Response res = await _api.get('/Usuario/$id');
    if (res.statusCode == 200) {
      return (res.data as Map).cast<String, dynamic>();
    }
    throw Exception('Entregador não encontrado');
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final Map<String, dynamic> payload = {
      ...body,
      'disponivel': body['disponivel'] ?? true,
    };
    final Response res = await _api.post('/Usuario/entregador', data: payload);
    if (res.statusCode == 201 || res.statusCode == 200) {
      if (res.data is Map) {
        return (res.data as Map).cast<String, dynamic>();
      }
      return payload;
    }
    throw Exception('Erro ao criar entregador: ${res.statusCode}');
  }

  Future<void> update(String id, Map<String, dynamic> body) async {
    final Response res = await _api.put('/Usuario/$id', data: body);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Erro ao atualizar: ${res.statusCode}');
    }
  }

  Future<void> delete(String id) async {
    final Response res = await _api.delete('/Usuario/$id');
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Erro ao excluir: ${res.statusCode}');
    }
  }

  Future<void> ativar(String id) async {
    final Response res = await _api.put('/Usuario/$id/ativar', data: {});
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Erro ao ativar: ${res.statusCode}');
    }
  }

  Future<void> desativar(String id) async {
    final Response res = await _api.put('/Usuario/$id/desativar', data: {});
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Erro ao desativar: ${res.statusCode}');
    }
  }
}
