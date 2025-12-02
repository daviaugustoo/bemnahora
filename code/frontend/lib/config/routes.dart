import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../pages/cartPage.dart';
import '../pages/dashboardPage.dart';
import '../pages/entregadoresCadastroPage.dart';
import '../pages/entregadoresListPage.dart';
import '../pages/loginPage.dart';
import '../pages/navigationHubPage.dart';
import '../pages/pedidoTabela.dart';
import '../pages/orderPage.dart';
import '../pages/productList.dart';
import '../pages/registerPage.dart';
import '../pages/registerProductPage.dart';
import '../pages/userCatalogPage.dart';
import '../pages/userListPage.dart';
import '../providers/authProvider.dart';

bool _isLoggedIn(BuildContext c) => c.read<AuthProvider>().isLoggedIn;
bool _isAdmin(BuildContext c) {
  final auth = c.read<AuthProvider>();
  return auth.isLoggedIn && auth.user?.role == UserType.admin;
}

bool _isEntregador(BuildContext c) =>
    c.read<AuthProvider>().user?.role == UserType.deliverer;
bool _isCliente(BuildContext c) =>
    c.read<AuthProvider>().user?.role == UserType.customer;
bool _isEmpresa(BuildContext c) =>
    c.read<AuthProvider>().user?.role == UserType.admin;

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
      redirect: (context, state) => _isAdmin(context) ? null : '/login',
    ),
    GoRoute(
      path: '/catalog',
      builder: (context, state) => const CatalogPage(),
      redirect: (context, state) => _isLoggedIn(context) ? null : '/login',
    ),
    GoRoute(
      path: '/registerProduct',
      builder: (context, state) => RegisterProductPage(),
      redirect: (context, state) => _isAdmin(context) ? null : '/login',
    ),
    GoRoute(
      path: '/productList',
      builder: (context, state) => const ProductList(),
      redirect: (context, state) => _isAdmin(context) ? null : '/login',
    ),
    GoRoute(
      path: '/userList',
      builder: (context, state) => const UserListPage(),
      redirect: (context, state) => _isAdmin(context) ? null : '/login',
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartPage(),
      redirect: (context, state) => _isLoggedIn(context) ? null : '/login',
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrdersPage(),
      redirect: (context, state) => _isLoggedIn(context) ? null : '/login',
    ),
    GoRoute(
      path: '/orders/:id',
      builder: (context, state) =>
          OrderPage(orderId: state.pathParameters['id'] ?? ''),
      redirect: (context, state) => _isLoggedIn(context) ? null : '/login',
    ),
    GoRoute(
      path: '/entregadores',
      builder: (context, state) => const EntregadoresListPage(),
      redirect: (context, state) => _isAdmin(context) ? null : '/login',
    ),
    GoRoute(
      path: '/entregadores/novo',
      builder: (context, state) => const EntregadoresCadastroPage(),
      redirect: (context, state) => _isAdmin(context) ? null : '/login',
    ),
    GoRoute(
      path: '/entregadores/editar/:id',
      builder: (context, state) =>
          EntregadoresCadastroPage(editId: state.pathParameters['id']),
      redirect: (context, state) => _isAdmin(context) ? null : '/login',
    ),
    GoRoute(
      path: '/hub',
      builder: (context, state) => const NavigationHubPage(),
      redirect: (context, state) => _isLoggedIn(context) ? null : '/login',
    ),
  ],
);

class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.construction, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Esta página está em desenvolvimento',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
