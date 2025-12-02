import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/authProvider.dart';
import '../models/user.dart';

class NavigationHubPage extends StatelessWidget {
  const NavigationHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn) {
      Future.microtask(() => context.go('/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final role = auth.user?.role;

    // Defina os cards por perfil
    final List<_NavItem> items;
    if (role == UserType.admin) {
      items = [
        _NavItem(
          title: 'Dashboard',
          icon: Icons.dashboard,
          route: '/dashboard',
          color: Colors.orange,
        ),
        _NavItem(
          title: 'Entregadores',
          icon: Icons.pedal_bike,
          route: '/entregadores',
          color: Colors.green,
        ),
        _NavItem(
          title: 'Produtos (Catálogo)',
          icon: Icons.inventory_2,
          route: '/catalog',
          color: Colors.blue,
        ),
        _NavItem(
          title: 'Pedidos',
          icon: Icons.receipt_long,
          route: '/orders',
          color: Colors.purple,
        ),
      ];
    } else if (role == UserType.customer) {
      items = [
        _NavItem(
          title: 'Produtos',
          icon: Icons.shopping_bag,
          route: '/catalog',
          color: Colors.blue,
        ),
        _NavItem(
          title: 'Meus Pedidos',
          icon: Icons.history,
          route: '/orders',
          color: Colors.teal,
        ),
        // _NavItem(title: 'Chat', icon: Icons.chat_bubble_outline, route: '/chat', color: Colors.indigo),
        // _NavItem(title: 'Carrinho', icon: Icons.shopping_cart, route: '/cart', color: Colors.deepOrange),
      ];
    } else if (role == UserType.admin) {
      items = [
        _NavItem(
          title: 'Produtos (Catálogo)',
          icon: Icons.inventory_2,
          route: '/catalog',
          color: Colors.blue,
        ),
        _NavItem(
          title: 'Pedidos',
          icon: Icons.receipt_long,
          route: '/orders',
          color: Colors.purple,
        ),
        _NavItem(
          title: 'Entregadores',
          icon: Icons.pedal_bike,
          route: '/entregadores',
          color: Colors.green,
        ),
        // _NavItem(title: 'Chat', icon: Icons.chat_bubble_outline, route: '/chat', color: Colors.indigo),
      ];
    } else if (role == UserType.deliverer) {
      items = [
        _NavItem(
          title: 'Minhas Entregas',
          icon: Icons.local_shipping,
          route: '/orders',
          color: Colors.green,
        ),
        // _NavItem(title: 'Chat', icon: Icons.chat_bubble_outline, route: '/chat', color: Colors.indigo),
      ];
    } else {
      // fallback
      items = [
        _NavItem(
          title: 'Produtos',
          icon: Icons.shopping_bag,
          route: '/catalog',
          color: Colors.blue,
        ),
        _NavItem(
          title: 'Pedidos',
          icon: Icons.receipt_long,
          route: '/orders',
          color: Colors.purple,
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navegação'),
        backgroundColor: const Color.fromARGB(255, 245, 146, 16),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _NavGrid(items: items),
        ),
      ),
    );
  }
}

class _NavItem {
  final String title;
  final IconData icon;
  final String route;
  final Color color;
  _NavItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.color,
  });
}

class _NavGrid extends StatelessWidget {
  final List<_NavItem> items;
  const _NavGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;
    final crossAxisCount = isWide ? 4 : 2;

    return GridView.builder(
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (_, i) {
        final item = items[i];
        return _NavCard(item: item);
      },
    );
  }
}

class _NavCard extends StatelessWidget {
  final _NavItem item;
  const _NavCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.color;
    return InkWell(
      onTap: () => context.go(item.route),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.12), color.withOpacity(0.03)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.12),
                foregroundColor: color,
                radius: 28,
                child: Icon(item.icon, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
