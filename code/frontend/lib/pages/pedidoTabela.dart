import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/entrega.dart';
import '../models/enums.dart';
import '../models/pedido.dart';
import '../models/user.dart';
import '../providers/authProvider.dart';
import '../services/api_service.dart';
import '../services/entrega_service.dart';
import '../services/pedido_service.dart';
import '../services/user_service.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late final PedidoService _pedidoService;
  late final EntregaService _entregaService;
  late final UserService _userService;
  final Map<String, User> _userCache = {};
  Future<List<_PedidoResumo>>? _future;
  String? _futureUserId;

  @override
  void initState() {
    super.initState();
    final api = context.read<ApiService>();
    _pedidoService = PedidoService(api);
    _entregaService = EntregaService(api);
    _userService = context.read<UserService>();
  }

  void _ensureFuture(User? user) {
    final id = user?.id;
    if (_future != null && _futureUserId == id) return;
    _futureUserId = id;
    if (user != null) {
      _userCache[user.id] = user;
    }
    _future = _load(user);
  }

  Future<List<_PedidoResumo>> _load(User? user) async {
    if (user == null) return const <_PedidoResumo>[];

    final pedidos = await _pedidoService.getAll();
    final entregas = await _fetchEntregas(user);
    final entregasByPedido = {
      for (final entrega in entregas)
        if (entrega.pedidoId.isNotEmpty) entrega.pedidoId: entrega,
    };

    final enrichedPedidos = <Pedido>[];
    final idsParaUsuarios = <String>{};

    for (final pedido in pedidos) {
      final entrega = pedido.id != null ? entregasByPedido[pedido.id!] : null;
      final enriched = pedido.copyWith(
        usuarioId: entrega?.consumidorId ?? pedido.usuarioId,
        empresaId: entrega?.distribuidoraId ?? pedido.empresaId,
        entregadorId: entrega?.entregadorId ?? pedido.entregadorId,
      );

      if (enriched.usuarioId != null && enriched.usuarioId!.isNotEmpty) {
        idsParaUsuarios.add(enriched.usuarioId!);
      }
      if (enriched.empresaId != null && enriched.empresaId!.isNotEmpty) {
        idsParaUsuarios.add(enriched.empresaId!);
      }
      if (enriched.entregadorId != null && enriched.entregadorId!.isNotEmpty) {
        idsParaUsuarios.add(enriched.entregadorId!);
      }

      enrichedPedidos.add(enriched);
    }

    final usuarios = await _loadUsers(idsParaUsuarios);

    final resumosRemotos = enrichedPedidos.map((pedido) {
      final entrega = pedido.id != null ? entregasByPedido[pedido.id!] : null;
      return _PedidoResumo(
        pedido: pedido,
        entrega: entrega,
        cliente: pedido.usuarioId != null ? usuarios[pedido.usuarioId!] : null,
        empresa: pedido.empresaId != null ? usuarios[pedido.empresaId!] : null,
        entregador: pedido.entregadorId != null
            ? usuarios[pedido.entregadorId!]
            : null,
        isLocal: false,
      );
    }).toList();

    final filtrados = _filtrarPorPerfil(resumosRemotos, user);
    final idsRemotos = filtrados
        .map((resumo) => resumo.pedido.id)
        .whereType<String>()
        .toSet();

    final locais = await _loadLocal(user, idsRemotos);
    final todos = [...locais, ...filtrados];
    todos.sort((a, b) => b.pedido.dataPedido.compareTo(a.pedido.dataPedido));
    return todos;
  }

  Future<List<Entrega>> _fetchEntregas(User user) async {
    try {
      switch (user.role) {
        case UserType.deliverer:
          return await _entregaService.getByEntregador(user.id);
        case UserType.customer:
          return await _entregaService.getByConsumidor(user.id);
        case UserType.admin:
          final propias = await _entregaService.getByDistribuidora(user.id);
          if (propias.isNotEmpty) return propias;
          return await _entregaService.getAll();
      }
    } catch (_) {
      return const <Entrega>[];
    }
  }

  Future<Map<String, User>> _loadUsers(Set<String> ids) async {
    final missing = ids
        .where((id) => id.isNotEmpty && !_userCache.containsKey(id))
        .toList();
    if (missing.isNotEmpty) {
      await Future.wait(
        missing.map((id) async {
          try {
            final user = await _userService.getUserById(id);
            _userCache[id] = user;
          } catch (_) {
            // Ignora falhas pontuais para não quebrar a listagem
          }
        }),
      );
    }
    return {
      for (final entry in _userCache.entries)
        if (ids.contains(entry.key)) entry.key: entry.value,
    };
  }

  Future<List<_PedidoResumo>> _loadLocal(
    User user,
    Set<String> pedidosRemotos,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list =
          prefs.getStringList('local_pending_pedidos') ?? const <String>[];
      final pedidos = <Pedido>[];
      final idsParaUsuarios = <String>{};

      for (final raw in list) {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          final pedido = Pedido.fromJson(map);
          if (pedido.id != null && pedidosRemotos.contains(pedido.id)) {
            continue;
          }

          final enriched = pedido.copyWith(
            usuarioId:
                pedido.usuarioId ??
                (user.role == UserType.customer ? user.id : pedido.usuarioId),
            empresaId:
                pedido.empresaId ??
                (user.role == UserType.admin ? user.id : pedido.empresaId),
            entregadorId:
                pedido.entregadorId ??
                (user.role == UserType.deliverer
                    ? user.id
                    : pedido.entregadorId),
          );

          if (!_pertenceAoUsuario(enriched, user)) continue;

          if (enriched.usuarioId != null && enriched.usuarioId != user.id) {
            idsParaUsuarios.add(enriched.usuarioId!);
          }
          if (enriched.entregadorId != null &&
              enriched.entregadorId != user.id) {
            idsParaUsuarios.add(enriched.entregadorId!);
          }
          if (enriched.empresaId != null && enriched.empresaId != user.id) {
            idsParaUsuarios.add(enriched.empresaId!);
          }

          pedidos.add(enriched);
        } catch (_) {
          // ignora entradas inválidas
        }
      }

      if (pedidos.isEmpty) return const <_PedidoResumo>[];

      final usuarios = await _loadUsers(idsParaUsuarios);

      return pedidos
          .map(
            (pedido) => _PedidoResumo(
              pedido: pedido,
              entrega: null,
              cliente: pedido.usuarioId == user.id
                  ? user
                  : (pedido.usuarioId != null
                        ? usuarios[pedido.usuarioId!]
                        : null),
              empresa: pedido.empresaId == user.id
                  ? user
                  : (pedido.empresaId != null
                        ? usuarios[pedido.empresaId!]
                        : null),
              entregador: pedido.entregadorId == user.id
                  ? user
                  : (pedido.entregadorId != null
                        ? usuarios[pedido.entregadorId!]
                        : null),
              isLocal: true,
            ),
          )
          .toList();
    } catch (_) {
      return const <_PedidoResumo>[];
    }
  }

  List<_PedidoResumo> _filtrarPorPerfil(
    List<_PedidoResumo> pedidos,
    User user,
  ) {
    switch (user.role) {
      case UserType.customer:
        return pedidos
            .where((resumo) => resumo.pedido.usuarioId == user.id)
            .toList();
      case UserType.deliverer:
        return pedidos
            .where((resumo) => resumo.pedido.entregadorId == user.id)
            .toList();
      case UserType.admin:
        final proprios = pedidos
            .where((resumo) => resumo.pedido.empresaId == user.id)
            .toList();
        return proprios.isNotEmpty ? proprios : pedidos;
    }
  }

  bool _pertenceAoUsuario(Pedido pedido, User user) {
    switch (user.role) {
      case UserType.customer:
        return pedido.usuarioId == user.id;
      case UserType.deliverer:
        return pedido.entregadorId == user.id;
      case UserType.admin:
        return pedido.empresaId == user.id;
    }
  }

  String _titleForRole(UserType role) {
    switch (role) {
      case UserType.admin:
        return 'Histórico de Vendas';
      case UserType.deliverer:
        return 'Minhas Entregas';
      case UserType.customer:
        return 'Meus Pedidos';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isLoggedIn) {
          Future.microtask(() => context.go('/login'));
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = auth.user;
        _ensureFuture(user);

        return Scaffold(
          appBar: AppBar(
            title: Text(_titleForRole(user!.role)),
            backgroundColor: const Color.fromARGB(255, 245, 146, 16),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    _future = _load(user);
                  });
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = _load(user);
              });
              await _future;
            },
            child: FutureBuilder<List<_PedidoResumo>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 120),
                      Center(child: Text('Erro: ${snapshot.error}')),
                    ],
                  );
                }
                final pedidos = snapshot.data ?? const <_PedidoResumo>[];
                if (pedidos.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 140),
                      Center(
                        child: Text(
                          'Nenhum pedido encontrado para o seu perfil.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                }
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: pedidos.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final resumo = pedidos[index];
                    final pedido = resumo.pedido;
                    final entrega = resumo.entrega;
                    final podeAbrir = !resumo.isLocal && pedido.id != null;

                    return ListTile(
                      enabled: podeAbrir,
                      leading: CircleAvatar(
                        backgroundColor: resumo.isLocal
                            ? Colors.orange.withOpacity(0.15)
                            : const Color.fromARGB(
                                255,
                                245,
                                146,
                                16,
                              ).withOpacity(0.15),
                        foregroundColor: const Color.fromARGB(
                          255,
                          245,
                          146,
                          16,
                        ),
                        child: Icon(
                          resumo.isLocal
                              ? Icons.offline_bolt
                              : Icons.receipt_long,
                        ),
                      ),
                      title: Text(
                        resumo.isLocal
                            ? 'Pedido pendente'
                            : 'Pedido ${pedido.id ?? ''}',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status: ${statusPedidoToString(pedido.status)}',
                          ),
                          if (entrega != null)
                            Text(
                              'Entrega: ${statusEntregaToString(entrega.status)}',
                            ),
                          if (pedido.entregadorId != null)
                            Text(
                              'Entregador: ${resumo.entregador?.displayName ?? pedido.entregadorId}',
                            ),
                          if (pedido.usuarioId != null)
                            Text(
                              'Cliente: ${resumo.cliente?.displayName ?? pedido.usuarioId}',
                            ),
                          if (pedido.empresaId != null)
                            Text(
                              'Empresa: ${resumo.empresa?.displayName ?? pedido.empresaId}',
                            ),
                        ],
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total: R\$ ${pedido.valorTotal.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Data: ${pedido.dataPedido.toLocal()}'
                                .split('.')
                                .first,
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (resumo.isLocal)
                            const Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Não enviado',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        if (!podeAbrir) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Este pedido ainda não foi sincronizado com o servidor.',
                              ),
                            ),
                          );
                          return;
                        }
                        context.go('/orders/${pedido.id}');
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _PedidoResumo {
  final Pedido pedido;
  final Entrega? entrega;
  final User? cliente;
  final User? empresa;
  final User? entregador;
  final bool isLocal;

  const _PedidoResumo({
    required this.pedido,
    required this.entrega,
    required this.cliente,
    required this.empresa,
    required this.entregador,
    required this.isLocal,
  });
}
