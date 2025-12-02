import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/env.dart';
import '../models/enums.dart';
import '../models/pedido.dart';
import '../models/user.dart';

import '../providers/authProvider.dart';
import '../providers/cartProvider.dart';
import '../services/api_service.dart';
import '../services/pedido_service.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, AuthProvider>(
      builder: (context, cart, auth, _) {
        final isEmpty = cart.isEmpty;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Carrinho'),
            backgroundColor: const Color.fromARGB(255, 245, 146, 16),
            foregroundColor: Colors.white,
          ),
          body: isEmpty
              ? const _EmptyCart()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: cart.items.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.inventory_2_outlined),
                            ),
                            title: Text(item.productName),
                            subtitle: Text('Qtd: ${item.quantity}'),
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'R\$ ${item.totalPrice.toStringAsFixed(2)}',
                                ),
                                const SizedBox(height: 4),
                                _QuantityPicker(
                                  quantity: item.quantity,
                                  onDecrease: () {
                                    final q = item.quantity - 1;
                                    if (q <= 0) {
                                      cart.removeItem(item.productId);
                                    } else {
                                      cart.updateQuantity(item.productId, q);
                                    }
                                  },
                                  onIncrease: () => cart.updateQuantity(
                                    item.productId,
                                    item.quantity + 1,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    _CartSummary(
                      total: cart.totalAmount,
                      onClear: cart.clear,
                      onCheckout: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final authState = context.read<AuthProvider>();

                        if (!authState.isLoggedIn || authState.user == null) {
                          context.go('/login');
                          return;
                        }

                        if (cart.isEmpty) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Adicione produtos antes de pagar.',
                              ),
                            ),
                          );
                          return;
                        }

                        try {
                          final user = authState.user!;
                          final pedido = Pedido(
                            id: null,
                            // inclui itens do carrinho para o backend
                            carrinho: Carrinho(
                              total: cart.totalAmount,
                              itens: cart.items,
                            ),
                            valorTotal: cart.totalAmount,
                            dataPedido: DateTime.now(),
                            status: StatusPedido.Pendente,
                            usuarioId: user.role == UserType.customer
                                ? user.id
                                : null,
                            empresaId: user.role == UserType.admin
                                ? user.id
                                : null,
                            entregadorId: user.role == UserType.deliverer
                                ? user.id
                                : null,
                          );

                          final pedidoService = PedidoService(
                            context.read<ApiService>(),
                          );
                          final created = await pedidoService.create(pedido);
                          if (created.id == null || created.id!.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Pedido criado sem ID. Verifique retorno do backend.',
                                ),
                              ),
                            );
                            return;
                          }
                          // Salvar pedido criado localmente como pendente para aparecer na lista
                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final key = 'local_pending_pedidos';
                            final list = prefs.getStringList(key) ?? <String>[];

                            // Garantir que o pedido salvo localmente tenha o userId para filtro
                            final mapa = created.toJson();
                            switch (user.role) {
                              case UserType.customer:
                                mapa['userId'] = user.id;
                                mapa['usuarioId'] = user.id;
                                mapa['consumidorId'] = user.id;
                                break;
                              case UserType.admin:
                                mapa['empresaId'] = user.id;
                                mapa['distribuidoraId'] = user.id;
                                break;
                              case UserType.deliverer:
                                mapa['entregadorId'] = user.id;
                                break;
                            }
                            list.add(jsonEncode(mapa));
                            await prefs.setStringList(key, list);
                          } catch (e) {
                            Logger().w(
                              'Não foi possível salvar pedido localmente: $e',
                            );
                          }

                          final payment = await pedidoService
                              .processarPagamento(
                                created.id!,
                                backUrl: _checkoutReturnUrl(),
                              );

                          final dynamic initPointDyn =
                              payment['initPoint'] ??
                              payment['init_point'] ??
                              payment['sandbox_init_point'];

                          String? urlParaAbrir;

                          if (initPointDyn != null) {
                            urlParaAbrir = initPointDyn.toString();
                          } else {
                            final prefId =
                                payment['preferenceId'] ??
                                payment['preference_id'];
                            if (prefId != null) {
                              urlParaAbrir =
                                  'https://www.mercadopago.com.br/checkout/v1/redirect?pref_id=$prefId';
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Preferência criada (ID: $prefId). Abrindo checkout...',
                                  ),
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          }

                          if (urlParaAbrir == null) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Falha: sem initPoint ou preferenceId',
                                ),
                              ),
                            );
                            return;
                          }

                          final uri = Uri.tryParse(urlParaAbrir);
                          if (uri == null ||
                              (uri.scheme != 'http' && uri.scheme != 'https')) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'URL inválida do pagamento: $urlParaAbrir',
                                ),
                              ),
                            );
                            return;
                          }

                          final launched = await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                          if (!launched) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Não foi possível abrir o pagamento',
                                ),
                              ),
                            );
                            return;
                          }

                          await cart.clear();
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Pagamento iniciado.'),
                            ),
                          );
                          if (context.mounted) {
                            context.go('/orders');
                          }
                        } on DioException catch (dioErr) {
                          final dynamic data = dioErr.response?.data;
                          String details =
                              dioErr.message ?? 'Erro desconhecido';

                          // coletar mensagens (se houver) para exibir em modal
                          final List<String> messages = [];

                          if (data is Map) {
                            if (data['errors'] is Map) {
                              final errs = data['errors'] as Map;
                              for (final v in errs.values) {
                                if (v is List && v.isNotEmpty) {
                                  messages.add(v.first.toString());
                                } else if (v is String) {
                                  messages.add(v);
                                } else {
                                  messages.add(v.toString());
                                }
                              }
                            } else if (data['title'] != null &&
                                data['detail'] != null) {
                              details =
                                  '${data['title'].toString()}: ${data['detail'].toString()}';
                            } else {
                              details = data.toString();
                            }
                          } else if (data is String) {
                            details = data;
                          } else if (data != null) {
                            details = data.toString();
                          }

                          if (messages.isNotEmpty) {
                            // mostrar diálogo modal com a lista de mensagens
                            if (context.mounted) {
                              showDialog<void>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text(
                                    'Erro ao iniciar pagamento',
                                  ),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: messages.length,
                                      separatorBuilder: (_, __) =>
                                          const Divider(),
                                      itemBuilder: (context, i) =>
                                          Text('• ${messages[i]}'),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } else {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Erro ao iniciar pagamento: $details',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Erro ao iniciar pagamento: $e'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.remove_shopping_cart,
              size: 72,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Seu carrinho está vazio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Adicione produtos ao carrinho para finalizar a compra.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 245, 146, 16),
              ),
              child: const Text('Ver produtos'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityPicker extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QuantityPicker({
    Key? key,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove, size: 18),
          onPressed: onDecrease,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          splashRadius: 18,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            quantity.toString(),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add, size: 18),
          onPressed: onIncrease,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          splashRadius: 18,
        ),
      ],
    );
  }
}

class _CartSummary extends StatelessWidget {
  final double total;
  final VoidCallback onClear;
  final Future<void> Function()? onCheckout;

  const _CartSummary({
    Key? key,
    required this.total,
    required this.onClear,
    this.onCheckout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: R\$ ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${total.toStringAsFixed(2)} itens',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onClear, child: const Text('Limpar')),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onCheckout == null
                ? null
                : () async {
                    await onCheckout!();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 245, 146, 16),
            ),
            child: const Text('Pagar'),
          ),
        ],
      ),
    );
  }
}

String _checkoutReturnUrl() {
  if (Env.checkoutReturnUrl.trim().isNotEmpty) {
    return Env.checkoutReturnUrl;
  }
  final base = Uri.tryParse(Env.apiBaseUrl);
  if (base == null) return 'https://www.mercadopago.com.br';
  final port = (base.hasPort && base.port != 80 && base.port != 443)
      ? ':${base.port}'
      : '';
  return '${base.scheme}://${base.host}$port';
}
