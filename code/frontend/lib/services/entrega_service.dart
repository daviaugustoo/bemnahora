import 'package:dio/dio.dart';

import '../models/entrega.dart';
import 'api_service.dart';

class EntregaService {
  final ApiService _api;
  EntregaService(this._api);

  Future<List<Entrega>> getAll() async {
    final Response res = await _api.get('/Entregas');
    if (res.statusCode == 200) {
      final data = res.data as List<dynamic>? ?? const <dynamic>[];
      return data
          .map(
            (item) => Entrega.fromJson((item as Map).cast<String, dynamic>()),
          )
          .toList();
    }
    throw Exception('Erro ao carregar entregas: ${res.statusCode}');
  }

  Future<List<Entrega>> getByEntregador(String entregadorId) =>
      _fetchList('/Entregas/por-entregador/$entregadorId');

  Future<List<Entrega>> getByDistribuidora(String distribuidoraId) =>
      _fetchList('/Entregas/por-distribuidora/$distribuidoraId');

  Future<List<Entrega>> getByConsumidor(String consumidorId) =>
      _fetchList('/Entregas/por-consumidor/$consumidorId');

  Future<Entrega?> getByPedido(String pedidoId) async {
    final Response res = await _api.get('/Entregas');
    if (res.statusCode == 200 && res.data is List) {
      for (final item in res.data as List) {
        final entrega = Entrega.fromJson((item as Map).cast<String, dynamic>());
        if (entrega.pedidoId == pedidoId) {
          return entrega;
        }
      }
      return null;
    }
    throw Exception('Não foi possível localizar a entrega do pedido $pedidoId');
  }

  Future<List<Entrega>> _fetchList(String path) async {
    final Response res = await _api.get(path);
    if (res.statusCode == 200) {
      final data = res.data as List<dynamic>? ?? const <dynamic>[];
      return data
          .map(
            (item) => Entrega.fromJson((item as Map).cast<String, dynamic>()),
          )
          .toList();
    }
    throw Exception('Erro ao carregar entregas em $path: ${res.statusCode}');
  }
}
