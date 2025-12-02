import 'enums.dart';
import 'cart.dart';

class Carrinho {
  final double total;
  final List<CartItem>? itens;

  Carrinho({required this.total, this.itens});

  factory Carrinho.fromJson(Map<String, dynamic> json) {
    final total = (json['total'] as num?)?.toDouble() ?? 0.0;
    List<CartItem>? itens;
    if (json['itens'] is List) {
      itens = (json['itens'] as List)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return Carrinho(total: total, itens: itens);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'total': total};
    if (itens != null) {
      // use backend format for each item
      map['itens'] = itens!.map((i) => i.toBackendJson()).toList();
    }
    return map;
  }
}

class Pedido {
  final String? id;
  final Carrinho carrinho;
  final double valorTotal;
  final DateTime dataPedido;
  final StatusPedido status;
  // Possíveis identificadores retornados pela API para vincular pedidos a usuários/entregadores/empresas
  final String? usuarioId; // consumidor/cliente
  final String? entregadorId;
  final String? empresaId; // distribuidora/empresa

  Pedido({
    this.id,
    required this.carrinho,
    required this.valorTotal,
    required this.dataPedido,
    required this.status,
    this.usuarioId,
    this.entregadorId,
    this.empresaId,
  });

  Pedido copyWith({
    String? id,
    Carrinho? carrinho,
    double? valorTotal,
    DateTime? dataPedido,
    StatusPedido? status,
    String? usuarioId,
    String? entregadorId,
    String? empresaId,
  }) {
    return Pedido(
      id: id ?? this.id,
      carrinho: carrinho ?? this.carrinho,
      valorTotal: valorTotal ?? this.valorTotal,
      dataPedido: dataPedido ?? this.dataPedido,
      status: status ?? this.status,
      usuarioId: usuarioId ?? this.usuarioId,
      entregadorId: entregadorId ?? this.entregadorId,
      empresaId: empresaId ?? this.empresaId,
    );
  }

  factory Pedido.fromJson(Map<String, dynamic> json) {
    String? readId(List<String> keys) {
      for (final key in keys) {
        if (!json.containsKey(key)) continue;
        final value = json[key];
        final extracted = _extractId(value);
        if (extracted != null && extracted.isNotEmpty) {
          return extracted;
        }
      }
      return null;
    }

    return Pedido(
      id: readId([
        'id',
        '_id',
        'Id',
        'ID',
        'pedidoId',
        'PedidoId',
        'PedidoID',
      ]),
      carrinho: Carrinho.fromJson(json['carrinho'] ?? {'total': 0}),
      valorTotal: (json['valorTotal'] as num?)?.toDouble() ?? 0.0,
      dataPedido: DateTime.tryParse(json['dataPedido'] ?? '') ?? DateTime.now(),
      status: json['status'] is String
          ? statusPedidoFromString(json['status'])
          : StatusPedido.values[(json['status'] ?? 0).clamp(
              0,
              StatusPedido.values.length - 1,
            )],
      usuarioId: readId([
        'userId',
        'usuarioId',
        'usuario',
        'UsuarioId',
        'consumidorId',
        'ConsumidorId',
        'clienteId',
        'ClienteId',
        'consumidor',
        'cliente',
      ]),
      entregadorId: readId([
        'entregadorId',
        'EntregadorId',
        'entregador',
      ]),
      empresaId: readId([
        'empresaId',
        'empresa',
        'EmpresaId',
        'distribuidoraId',
        'DistribuidoraId',
        'distribuidora',
      ]),
    );
  }


  Map<String, dynamic> toJson() {
    final map = {
      if (id != null) 'id': id,
      'carrinho': carrinho.toJson(),
      'valorTotal': valorTotal,
      'dataPedido': dataPedido.toIso8601String(),
      // enviar status como número (índice do enum) para compatibilidade com o backend
      'status': status.index,
    };
    if (usuarioId != null) map['userId'] = usuarioId;
    if (entregadorId != null) map['entregadorId'] = entregadorId;
    if (empresaId != null) map['empresaId'] = empresaId;
    return map;
  }
}

String? _extractId(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final match = _objectIdPattern.firstMatch(trimmed);
    return match?.group(1) ?? trimmed;
  }
  if (value is num || value is bool) {
    return value.toString();
  }
  if (value is Map) {
    for (final key in [
      'id',
      '_id',
      'Id',
      'ID',
      r'$id',
      r'$Id',
      r'$ID',
      r'$oid',
      'oid',
      'Oid',
      'OID',
      'value',
      'Value',
    ]) {
      if (value.containsKey(key)) {
        final nested = _extractId(value[key]);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    }
    for (final entry in value.entries) {
      final nested = _extractId(entry.value);
      if (nested != null && nested.isNotEmpty) {
        return nested;
      }
    }
  }
  final text = value.toString();
  if (text.isEmpty) return null;
  final match = _objectIdPattern.firstMatch(text);
  return match?.group(1) ?? text;
}

final RegExp _objectIdPattern = RegExp(r'([a-fA-F0-9]{24})');
