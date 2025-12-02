import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/pedido.dart';
import '../models/enums.dart';

class PedidoService {
  final ApiService _api;
  PedidoService(this._api);

  Future<List<Pedido>> getAll() async {
    final Response res = await _api.get('/Pedido');
    if (res.statusCode == 200) {
      final list = (res.data as List)
          .map((e) => Pedido.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    }
    throw Exception('Erro ao carregar pedidos: ${res.statusCode}');
  }

  Future<Pedido> getById(String id) async {
    final Response res = await _api.get('/Pedido/$id');
    if (res.statusCode == 200) {
      return Pedido.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception('Pedido não encontrado');
  }

  Future<Pedido> create(Pedido p) async {
    final Response res = await _api.post('/Pedido', data: p.toJson());
    if (res.statusCode == 201 || res.statusCode == 200) {
      return Pedido.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception('Erro ao criar pedido: ${res.statusCode} ${res.data}');
  }

  Future<void> update(String id, Pedido p) async {
    final Response res = await _api.put('/Pedido/$id', data: p.toJson());
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception(
        'Erro ao atualizar pedido: ${res.statusCode} ${res.data}',
      );
    }
  }

  Future<void> delete(String id) async {
    final Response res = await _api.delete('/Pedido/$id');
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('Erro ao excluir pedido: ${res.statusCode}');
    }
  }

  Future<void> alterarStatus(String id, StatusPedido novo) async {
    final Response res = await _api.put(
      '/Pedido/$id/status',
      data: novo.name,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('Erro ao alterar status: ${res.statusCode} ${res.data}');
    }
  }

  Future<Map<String, dynamic>> processarPagamentoViaPedido(String id) async {
    final Response res = await _api.post('/Pedido/$id/pagamento');
    if (res.statusCode == 200) {
      if (res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      } else if (res.data is Map) {
        return Map<String, dynamic>.from(res.data as Map);
      }
    }
    throw Exception(
      'Erro ao processar pagamento: ${res.statusCode} ${res.data}',
    );
  }

  Future<Map<String, dynamic>> processarPagamento(
    String id, {
    String? backUrl,
  }) async {
    final Map<String, dynamic>? queryParameters =
        (backUrl == null || backUrl.isEmpty) ? null : {'backUrl': backUrl};
    final Response res = await _api.post(
      '/pagamento/pagar/$id',
      queryParameters: queryParameters,
    );
    if (res.statusCode == 200) {
      if (res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      } else if (res.data is Map) {
        return Map<String, dynamic>.from(res.data as Map);
      }
      throw Exception('Resposta inesperada do pagamento: ${res.data}');
    }
    throw Exception(
      'Erro ao processar pagamento: ${res.statusCode} ${res.data}',
    );
  }
}
