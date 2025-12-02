import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/entrega.dart';
import '../models/enums.dart';
import '../models/pedido.dart';
import '../models/user.dart';
import '../providers/authProvider.dart';
import '../providers/chatProvider.dart';
import '../services/api_service.dart';
import '../services/entrega_service.dart';
import '../services/pedido_service.dart';
import '../services/user_service.dart';

class OrderPage extends StatefulWidget {
  final String orderId;

  const OrderPage({super.key, required this.orderId});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  Pedido? _pedido;
  Entrega? _entrega;
  User? _cliente;
  User? _empresa;
  User? _entregador;
  bool _loading = true;
  bool _initialFetchDone = false;
  final TextEditingController _ctrl = TextEditingController();
  Timer? _pollTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialFetchDone) return;
    _initialFetchDone = true;
    _loadAll();
    _pollTimer ??= Timer.periodic(
      const Duration(seconds: 5),
      (_) => _atualizarStatusPeriodico(),
    );
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final api = context.read<ApiService>();
      final pedidoService = PedidoService(api);
      final rawPedido = await pedidoService.getById(widget.orderId);

      final entregaService = context.read<EntregaService>();
      Entrega? entrega;
      try {
        entrega = await entregaService.getByPedido(widget.orderId);
      } catch (_) {
        entrega = null;
      }

      final clienteId = entrega?.consumidorId ?? rawPedido.usuarioId;
      final empresaId = entrega?.distribuidoraId ?? rawPedido.empresaId;
      final entregadorId = entrega?.entregadorId ?? rawPedido.entregadorId;

      final enrichedPedido = rawPedido.copyWith(
        usuarioId: clienteId,
        empresaId: empresaId,
        entregadorId: entregadorId,
      );

      final ids = <String>{};
      if (clienteId != null && clienteId.isNotEmpty) ids.add(clienteId);
      if (empresaId != null && empresaId.isNotEmpty) ids.add(empresaId);
      if (entregadorId != null && entregadorId.isNotEmpty)
        ids.add(entregadorId);

      final participantes = await _buscarUsuarios(ids);

      final token = await api.getToken();
      if (token != null) {
        try {
          await context.read<ChatProvider>().connect(widget.orderId, token);
        } catch (_) {
          // falha silenciosa, continua exibindo detalhes
        }
      }

      setState(() {
        _pedido = enrichedPedido;
        _entrega = entrega;
        _cliente = clienteId != null ? participantes[clienteId] : _cliente;
        _empresa = empresaId != null ? participantes[empresaId] : _empresa;
        _entregador = entregadorId != null
            ? participantes[entregadorId]
            : _entregador;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar pedido: $e')));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _atualizarStatusPeriodico() async {
    if (!mounted) return;
    try {
      final api = context.read<ApiService>();
      final pedidoService = PedidoService(api);
      final pedidoAtualizado = await pedidoService.getById(widget.orderId);

      Entrega? entregaAtualizada = _entrega;
      try {
        entregaAtualizada = await context.read<EntregaService>().getByPedido(
          widget.orderId,
        );
      } catch (_) {
        // mantém última entrega conhecida
      }

      final clienteId =
          entregaAtualizada?.consumidorId ?? pedidoAtualizado.usuarioId;
      final empresaId =
          entregaAtualizada?.distribuidoraId ?? pedidoAtualizado.empresaId;
      final entregadorId =
          entregaAtualizada?.entregadorId ?? pedidoAtualizado.entregadorId;

      setState(() {
        _pedido = pedidoAtualizado.copyWith(
          usuarioId: clienteId,
          empresaId: empresaId,
          entregadorId: entregadorId,
        );
        _entrega = entregaAtualizada ?? _entrega;
      });
    } catch (_) {
      // Ignora oscilações de rede
    }
  }

  Future<Map<String, User>> _buscarUsuarios(Set<String> ids) async {
    if (ids.isEmpty) return const {};
    final userService = context.read<UserService>();
    final resultados = await Future.wait(
      ids.map((id) async {
        try {
          final user = await userService.getUserById(id);
          return MapEntry(id, user);
        } catch (_) {
          return null;
        }
      }),
    );
    return {
      for (final entry in resultados)
        if (entry != null) entry.key: entry.value,
    };
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _pollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final auth = context.watch<AuthProvider>();
    final pedido = _pedido;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido ${pedido?.id ?? widget.orderId}'),
        backgroundColor: const Color.fromARGB(255, 245, 146, 16),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (pedido != null) _buildHeader(pedido, auth.user),
                const Divider(height: 1),
                Expanded(child: _buildChatArea(chat, auth.user)),
                _buildInputRow(auth, chat),
              ],
            ),
    );
  }

  Widget _buildHeader(Pedido pedido, User? currentUser) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status do pedido: ${statusPedidoToString(pedido.status)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (_entrega != null) ...[
            const SizedBox(height: 4),
            Text(
              'Status da entrega: ${statusEntregaToString(_entrega!.status)}',
            ),
          ],
          const SizedBox(height: 6),
          Text('Total: R\$ ${pedido.valorTotal.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          Text('Data: ${pedido.dataPedido.toLocal()}'.split('.').first),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (_cliente != null || pedido.usuarioId != null)
                _infoChip(
                  Icons.person,
                  'Cliente',
                  _cliente?.displayName ?? pedido.usuarioId ?? '—',
                ),
              if (_entregador != null || pedido.entregadorId != null)
                _infoChip(
                  Icons.local_shipping,
                  'Entregador',
                  _entregador?.displayName ?? pedido.entregadorId ?? '—',
                ),
              if (_empresa != null || pedido.empresaId != null)
                _infoChip(
                  Icons.store,
                  'Empresa',
                  _empresa?.displayName ?? pedido.empresaId ?? '—',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _mensagemOrientacaoChat(currentUser),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea(ChatProvider chat, User? currentUser) {
    final messages = chat.messages;
    if (messages.isEmpty) {
      return const Center(child: Text('Sem mensagens ainda.'));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });

    final userId = currentUser?.id;
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = userId != null && userId == message.remetenteId;
        final time = DateFormat.Hm().format(message.enviadoEmUtc.toLocal());
        final sender = _nomeDoRemetente(message);

        final bubble = Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isMe
                ? const Color.fromARGB(255, 245, 146, 16)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isMe ? 12 : 0),
              topRight: Radius.circular(isMe ? 0 : 12),
              bottomLeft: const Radius.circular(12),
              bottomRight: const Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Text(
                  sender,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              Text(
                message.texto,
                style: TextStyle(color: isMe ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.black45,
                  ),
                ),
              ),
            ],
          ),
        );

        return Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 16,
                  child: Text(
                    sender.isNotEmpty ? sender[0].toUpperCase() : '?',
                  ),
                ),
              ),
            Flexible(child: bubble),
            if (isMe)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color.fromARGB(255, 245, 146, 16),
                  child: const Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInputRow(AuthProvider auth, ChatProvider chat) {
    final user = auth.user;
    final podeEnviar = _usuarioPodeEnviar(user);

    if (!podeEnviar) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'Você está visualizando o chat deste pedido. Apenas participantes podem enviar mensagens.',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final placeholder = _placeholderMensagem(user);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                decoration: InputDecoration(
                  hintText: placeholder ?? 'Digite uma mensagem...',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                final text = _ctrl.text.trim();
                if (text.isEmpty) return;
                final remetenteId = user?.id ?? 'anon';
                final remetenteTipo = user?.role != null
                    ? _remetenteTipoBackend(user!.role)
                    : 'Consumidor';
                try {
                  await chat.send(
                    widget.orderId,
                    remetenteId,
                    remetenteTipo,
                    text,
                  );
                  _ctrl.clear();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Erro ao enviar: $e')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  String _mensagemOrientacaoChat(User? user) {
    if (user == null) return 'Faça login para participar do chat deste pedido.';
    switch (user.role) {
      case UserType.deliverer:
        final nome = _cliente?.displayName ?? 'cliente';
        return 'Você está conversando diretamente com $nome sobre este pedido.';
      case UserType.admin:
        final nome = _cliente?.displayName ?? 'cliente';
        return 'Use este canal para apoiar $nome e acompanhar o andamento da entrega.';
      case UserType.customer:
        final interlocutor =
            _entregador?.displayName ??
            _empresa?.displayName ??
            'a equipe de entrega';
        return 'Converse com $interlocutor para combinar detalhes ou tirar dúvidas.';
    }
  }

  bool _usuarioPodeEnviar(User? user) {
    if (user == null) return false;
    final participantes = <String>{};
    if (_pedido?.usuarioId != null) participantes.add(_pedido!.usuarioId!);
    if (_pedido?.entregadorId != null)
      participantes.add(_pedido!.entregadorId!);
    if (_pedido?.empresaId != null) participantes.add(_pedido!.empresaId!);
    if (_entrega?.consumidorId != null)
      participantes.add(_entrega!.consumidorId!);
    if (_entrega?.entregadorId != null)
      participantes.add(_entrega!.entregadorId!);
    if (_entrega?.distribuidoraId != null)
      participantes.add(_entrega!.distribuidoraId!);
    return participantes.contains(user.id);
  }

  String? _placeholderMensagem(User? user) {
    if (user == null) return null;
    switch (user.role) {
      case UserType.deliverer:
        return 'Envie uma atualização para o cliente';
      case UserType.admin:
        return 'Escreva sua mensagem para o cliente';
      case UserType.customer:
        return _entregador != null
            ? 'Envie uma mensagem para ${_entregador!.displayName}'
            : 'Envie uma mensagem para a empresa';
    }
  }

  String _remetenteTipoBackend(UserType role) {
    switch (role) {
      case UserType.admin:
        return 'Distribuidora';
      case UserType.deliverer:
        return 'Entregador';
      case UserType.customer:
        return 'Consumidor';
    }
  }

  String _nomeDoRemetente(ChatMessageVM mensagem) {
    if (_cliente?.id == mensagem.remetenteId) return _cliente!.displayName;
    if (_entregador?.id == mensagem.remetenteId)
      return _entregador!.displayName;
    if (_empresa?.id == mensagem.remetenteId) return _empresa!.displayName;

    final tipo = mensagem.remetenteTipo.trim();
    if (tipo.isEmpty) return 'Participante';
    switch (tipo.toLowerCase()) {
      case 'distribuidora':
        return 'Distribuidora';
      case 'entregador':
        return 'Entregador';
      case 'consumidor':
        return 'Consumidor';
      case 'admin':
        return 'Empresa';
      default:
        return tipo[0].toUpperCase() + tipo.substring(1);
    }
  }
}
