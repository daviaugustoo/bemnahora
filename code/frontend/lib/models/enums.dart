enum StatusPedido { Pendente, Pago, Enviado, Cancelado }

StatusPedido statusPedidoFromString(String s) {
  return StatusPedido.values.firstWhere(
    (e) => e.name.toLowerCase() == s.toLowerCase(),
  );
}

String statusPedidoToString(StatusPedido s) => s.name;
