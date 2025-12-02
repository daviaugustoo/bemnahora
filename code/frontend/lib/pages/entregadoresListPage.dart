import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../services/entregador_service.dart';
import '../providers/authProvider.dart';
import '../models/user.dart';

class EntregadoresListPage extends StatefulWidget {
  const EntregadoresListPage({super.key});

  @override
  State<EntregadoresListPage> createState() => _EntregadoresListPageState();
}

class _EntregadoresListPageState extends State<EntregadoresListPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _list = [];

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final svc = context.read<EntregadorService>();
      final res = await svc.getAll();
      setState(() {
        _list = res;
        _loading = false;
      });
    } on DioException catch (e) {
      setState(() {
        _error = 'Erro: ${e.response?.statusCode}';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro: $e';
        _loading = false;
      });
    }
  }

  Future<void> _toggleAtivo(Map<String, dynamic> e) async {
    final svc = context.read<EntregadorService>();
    final bool ativo = (e['ativo'] == true);
    try {
      if (ativo) {
        await svc.desativar(e['id'] ?? e['_id']);
      } else {
        await svc.ativar(e['id'] ?? e['_id']);
      }
      await _load();
    } catch (err) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $err')));
    }
  }

  Future<void> _delete(Map<String, dynamic> e) async {
    final svc = context.read<EntregadorService>();
    try {
      await svc.delete(e['id'] ?? e['_id']);
      await _load();
    } catch (err) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $err')));
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _list;
    return _list.where((e) {
      final nome = (e['nome'] ?? e['username'] ?? '').toString().toLowerCase();
      final tel = (e['telefone'] ?? '').toString().toLowerCase();
      final doc = (e['cnh'] ?? e['documento'] ?? '').toString().toLowerCase();
      return nome.contains(q) || tel.contains(q) || doc.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn || auth.user?.role != UserType.admin) {
      Future.microtask(() => context.go('/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entregadores'),
        backgroundColor: const Color.fromARGB(255, 245, 146, 16),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Novo entregador',
            onPressed: () => context.go('/entregadores/novo'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                labelText: 'Buscar por nome, telefone ou CNH',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : _filtered.isEmpty
                ? const Center(child: Text('Nenhum entregador encontrado'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final e = _filtered[i];
                      final ativo = e['disponivel'] == true;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: ativo
                              ? Colors.green.shade100
                              : Colors.grey.shade200,
                          foregroundColor: ativo
                              ? Colors.green.shade800
                              : Colors.grey.shade800,
                          child: const Icon(Icons.pedal_bike),
                        ),
                        title: Text(e['nome'] ?? e['username'] ?? 'Entregador'),
                        subtitle: Text(
                          [
                            if ((e['telefone'] ?? '').toString().isNotEmpty)
                              'Tel: ${e['telefone']}',
                            if ((e['cnh'] ?? e['documento'] ?? '')
                                .toString()
                                .isNotEmpty)
                              'CNH: ${e['cnh'] ?? e['documento']}',
                            if ((e['email'] ?? '').toString().isNotEmpty)
                              'Email: ${e['email']}',
                          ].join('  •  '),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: ativo
                                  ? 'Marcar indisponível'
                                  : 'Marcar disponível',
                              icon: Icon(
                                ativo ? Icons.toggle_on : Icons.toggle_off,
                                color: ativo ? Colors.green : Colors.grey,
                              ),
                              onPressed: () => _toggleAtivo(e),
                            ),
                            IconButton(
                              tooltip: 'Editar',
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                final id = e['id'] ?? e['_id'];
                                if (id != null)
                                  context.go('/entregadores/editar/$id');
                              },
                            ),
                            IconButton(
                              tooltip: 'Excluir',
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => _delete(e),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
