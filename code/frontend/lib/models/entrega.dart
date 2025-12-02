enum StatusEntrega {
  criada,
  aguardandoRetirada,
  emTransito,
  entregue,
  cancelada,
}

StatusEntrega statusEntregaFrom(dynamic raw) {
  if (raw is int) {
    if (raw >= 0 && raw < StatusEntrega.values.length) {
      return StatusEntrega.values[raw];
    }
    return StatusEntrega.criada;
  }
  final text = raw?.toString().toLowerCase().trim();
  switch (text) {
    case 'aguardandoretirada':
    case 'aguardando_retirada':
      return StatusEntrega.aguardandoRetirada;
    case 'emtransito':
    case 'em_transito':
      return StatusEntrega.emTransito;
    case 'entregue':
      return StatusEntrega.entregue;
    case 'cancelada':
      return StatusEntrega.cancelada;
    default:
      return StatusEntrega.criada;
  }
}

String statusEntregaToString(StatusEntrega status) {
  switch (status) {
    case StatusEntrega.criada:
      return 'Criada';
    case StatusEntrega.aguardandoRetirada:
      return 'Aguardando retirada';
    case StatusEntrega.emTransito:
      return 'Em trânsito';
    case StatusEntrega.entregue:
      return 'Entregue';
    case StatusEntrega.cancelada:
      return 'Cancelada';
  }
}

class Entrega {
  final String? id;
  final String pedidoId;
  final String? entregadorId;
  final String? distribuidoraId;
  final String? consumidorId;
  final String? enderecoEntrega;
  final StatusEntrega status;
  final DateTime dataCriacao;
  final DateTime? dataPrevista;
  final DateTime? dataEntrega;

  const Entrega({
    required this.id,
    required this.pedidoId,
    required this.entregadorId,
    required this.distribuidoraId,
    required this.consumidorId,
    required this.enderecoEntrega,
    required this.status,
    required this.dataCriacao,
    required this.dataPrevista,
    required this.dataEntrega,
  });

  factory Entrega.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    String? readId(List<String> keys) {
      for (final key in keys) {
        if (!json.containsKey(key)) continue;
        final value = json[key];
        if (value == null) continue;
        if (value is Map) {
          final map = value.cast<String, dynamic>();
          final nested = map['id'] ?? map['_id'];
          if (nested != null) return nested.toString();
        } else {
          return value.toString();
        }
      }
      return null;
    }

    final pedidoId = readId(['pedidoId', 'pedido', 'PedidoId']) ?? '';

    return Entrega(
      id: readId(['id', '_id', 'Id', 'ID']),
      pedidoId: pedidoId,
      entregadorId: readId(['entregadorId', 'EntregadorId', 'entregador']),
      distribuidoraId: readId([
        'distribuidoraId',
        'DistribuidoraId',
        'empresaId',
        'empresa',
      ]),
      consumidorId: readId([
        'consumidorId',
        'ConsumidorId',
        'clienteId',
        'cliente',
        'usuarioId',
      ]),
      enderecoEntrega: json['enderecoEntrega']?.toString(),
      status: statusEntregaFrom(
        json['status'] ?? json['Status'] ?? json['statusEntrega'],
      ),
      dataCriacao:
          parseDate(json['dataCriacao'] ?? json['DataCriacao']) ??
          DateTime.now(),
      dataPrevista: parseDate(json['dataPrevista'] ?? json['DataPrevista']),
      dataEntrega: parseDate(json['dataEntrega'] ?? json['DataEntrega']),
    );
  }
}
