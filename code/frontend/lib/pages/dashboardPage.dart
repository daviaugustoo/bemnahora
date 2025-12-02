import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/authProvider.dart';
import '../services/api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final ApiService _api;

  Map<String, dynamic>? _pedidoStats;
  Map<String, dynamic>? _produtoStats;
  List<dynamic> _ultimosPedidos = [];
  List<dynamic> _entregadoresAtivos = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiService>();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resPedidos = await _api.get('/Pedido/estatisticas');
      final resProdutos = await _api.get('/Produto/estatisticas');
      final resUltimos = await _api.get('/Pedido/ultimos?limit=10');
      final resEntregadores = await _api.get('/Entregador/ativos');

      setState(() {
        _pedidoStats = (resPedidos.data as Map?)?.cast<String, dynamic>();
        _produtoStats = (resProdutos.data as Map?)?.cast<String, dynamic>();
        _ultimosPedidos = (resUltimos.data as List?) ?? [];
        _entregadoresAtivos = (resEntregadores.data as List?) ?? [];
        _loading = false;
      });
    } on DioException catch (e) {
      setState(() {
        _error =
            'Erro ao carregar dashboard: ${e.response?.statusCode ?? e.message}';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar dashboard: $e';
        _loading = false;
      });
    }
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
        title: const Text('Dashboard'),
        backgroundColor: const Color.fromARGB(255, 245, 146, 16),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : RefreshIndicator(
              onRefresh: _loadAll,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _StatCard(
                        title: 'Total de Pedidos',
                        value: '${_pedidoStats?['totalPedidos'] ?? '-'}',
                        icon: Icons.receipt_long,
                      ),
                      _StatCard(
                        title: 'Pedidos Hoje',
                        value: '${_pedidoStats?['pedidosHoje'] ?? '-'}',
                        icon: Icons.today,
                      ),
                      _StatCard(
                        title: 'Receita Total',
                        value:
                            'R\$ ${(_pedidoStats?['receitaTotal'] ?? 0).toString()}',
                        icon: Icons.payments,
                      ),
                      _StatCard(
                        title: 'Receita Hoje',
                        value:
                            'R\$ ${(_pedidoStats?['receitaHoje'] ?? 0).toString()}',
                        icon: Icons.attach_money,
                      ),
                      _StatCard(
                        title: 'Produtos',
                        value: '${_produtoStats?['totalProdutos'] ?? '-'}',
                        icon: Icons.inventory_2,
                      ),
                      _StatCard(
                        title: 'Estoque Baixo',
                        value: '${_produtoStats?['estoqueBaixo'] ?? '-'}',
                        icon: Icons.warning_amber_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _Section(
                          title: 'Últimos Pedidos',
                          child: _UltimosPedidosList(list: _ultimosPedidos),
                          onViewAll: () => context.go('/orders'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _Section(
                          title: 'Entregadores Ativos',
                          child: _EntregadoresAtivosList(
                            list: _entregadoresAtivos,
                          ),
                          onViewAll: () => context.go('/entregadores'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      drawer: _AdminDrawer(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 110,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.orange.shade100,
                foregroundColor: Colors.deepOrange,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onViewAll;
  const _Section({
    required this.title,
    required this.child,
    required this.onViewAll,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(onPressed: onViewAll, child: const Text('Ver tudo')),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(height: 320, child: child),
          ],
        ),
      ),
    );
  }
}

class _UltimosPedidosList extends StatelessWidget {
  final List<dynamic> list;
  const _UltimosPedidosList({required this.list});
  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return const Center(child: Text('Sem dados'));
    }
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, i) {
        final p = list[i] as Map<String, dynamic>;
        return ListTile(
          leading: const Icon(Icons.receipt),
          title: Text('Pedido ${p['id'] ?? p['_id'] ?? ''}'),
          subtitle: Text('Status: ${p['status'] ?? '-'}'),
          trailing: Text('R\$ ${p['valorTotal'] ?? '-'}'),
        );
      },
    );
  }
}

class _EntregadoresAtivosList extends StatelessWidget {
  final List<dynamic> list;
  const _EntregadoresAtivosList({required this.list});
  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return const Center(child: Text('Sem dados'));
    }
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, i) {
        final e = list[i] as Map<String, dynamic>;
        return ListTile(
          leading: const Icon(Icons.pedal_bike),
          title: Text(e['nome'] ?? e['username'] ?? 'Entregador'),
          subtitle: Text(e['telefone'] ?? ''),
          trailing: const Icon(Icons.check_circle, color: Colors.green),
        );
      },
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Center(
                child: Text(
                  'Admin',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => context.go('/dashboard'),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Produtos'),
              onTap: () => context.go('/productList'),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Usuários'),
              onTap: () => context.go('/userList'),
            ),
            ListTile(
              leading: const Icon(Icons.pedal_bike),
              title: const Text('Entregadores'),
              onTap: () => context.go('/entregadores'),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Pedidos'),
              onTap: () => context.go('/orders'),
            ),
          ],
        ),
      ),
    );
  }
}
