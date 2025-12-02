import 'package:flutter/material.dart';
import '../../../models/enums.dart';

class PedidoStatusDialog extends StatefulWidget {
  final StatusPedido statusAtual;
  const PedidoStatusDialog({super.key, required this.statusAtual});

  @override
  State<PedidoStatusDialog> createState() => _PedidoStatusDialogState();
}

class _PedidoStatusDialogState extends State<PedidoStatusDialog> {
  late StatusPedido _status;

  @override
  void initState() {
    super.initState();
    _status = widget.statusAtual;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alterar status'),
      content: DropdownButton<StatusPedido>(
        value: _status,
        items: StatusPedido.values
            .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
            .toList(),
        onChanged: (v) => setState(() => _status = v ?? _status),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _status),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
