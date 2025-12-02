import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/authProvider.dart';
import '../models/models.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        if (user == null) {
          return Drawer(
            child: ListView(
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Text(
                    'Bem na Hora',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Entrar'),
                  onTap: () => context.go('/login'),
                ),
              ],
            ),
          );
        }

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(user.displayName),
                accountEmail: Text(user.username),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: user.imagem != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            user.imagem!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                color: Color.fromARGB(255, 245, 146, 16),
                                size: 30,
                              );
                            },
                          ),
                        )
                      : const Icon(Icons.person, color: Colors.blue, size: 30),
                ),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 245, 146, 16),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () => context.go('/dashboard'),
              ),
              const Divider(),
              ..._getMenuItemsForUserType(context, user.role),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () {
                  authProvider.logout();
                  context.go('/');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _getMenuItemsForUserType(
    BuildContext context,
    UserType userType,
  ) {
    switch (userType) {
      case UserType.admin:
        return [
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Produtos'),
            onTap: () => context.go('/productList'),
          ),
          ListTile(
            leading: const Icon(Icons.person_4),
            title: const Text('Clientes'),
            onTap: () => context.go("/userList"),
          ),
          ListTile(
            leading: const Icon(Icons.production_quantity_limits_rounded),
            title: const Text("Gerenciar Produtos"),
            onTap: () => context.go('/registerProduct'),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Pedidos'),
            onTap: () => context.go('/orders'),
          ),

          ListTile(
            leading: const Icon(Icons.local_shipping),
            title: const Text('Entregas'),
            onTap: () => context.go('/deliveries'),
          ),
        ];
      case UserType.customer:
        return [
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Catálogo'),
            onTap: () => context.go('/catalog'),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Carrinho'),
            onTap: () => context.go('/cart'),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Meus Pedidos'),
            onTap: () => context.go('/orders'),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Rastreamento'),
            onTap: () => context.go('/tracking'),
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chat'),
            onTap: () => context.go('/chat'),
          ),
        ];
      case UserType.deliverer:
        return [
          ListTile(
            leading: const Icon(Icons.local_shipping),
            title: const Text('Minhas Entregas'),
            onTap: () => context.go('/deliveries'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Histórico'),
            onTap: () => context.go('/delivery-history'),
          ),
          ListTile(
            leading: const Icon(Icons.route),
            title: const Text('Rotas'),
            onTap: () => context.go('/routes'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () => context.go('/profile'),
          ),
        ];
    }
  }
}
