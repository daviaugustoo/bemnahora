import 'package:bem_na_hora_flutter/providers/userProvider.dart';
import 'package:bem_na_hora_flutter/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/routes.dart';
import 'providers/authProvider.dart';
import 'providers/chatProvider.dart';
import 'providers/cartProvider.dart';
import 'providers/productProvider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/entregador_service.dart';
import 'services/entrega_service.dart';
import 'services/product_service.dart';

void main() {
  runApp(const BemNaHoraApp());
}

class BemNaHoraApp extends StatelessWidget {
  const BemNaHoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<AuthService>(
          create: (context) => AuthService(context.read<ApiService>()),
        ),
        Provider<ProductService>(
          create: (context) => ProductService(context.read<ApiService>()),
        ),
        Provider<UserService>(
          create: (context) => UserService(context.read<ApiService>()),
        ),
        Provider<EntregadorService>(
          create: (context) => EntregadorService(context.read<ApiService>()),
        ),
        Provider<EntregaService>(
          create: (context) => EntregaService(context.read<ApiService>()),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (context) => ProductProvider(context.read<ProductService>()),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, auth, cart) =>
              (cart ?? CartProvider())..attachUser(auth.user?.id),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(
            context.read<UserService>(),
            context.read<AuthService>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Bem na Hora - Distribuidora Digital',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
