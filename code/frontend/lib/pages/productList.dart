import 'package:bem_na_hora_flutter/widgets/productCardAdmin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/productProvider.dart';
import '../providers/cartProvider.dart';
import '../providers/authProvider.dart';
import '../widgets/appDrawer.dart';
import '../models/models.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final authProvider = context.read<AuthProvider>();
      await authProvider.loadAuthStatus();

      if (!authProvider.isLoggedIn ||
          authProvider.user?.role != UserType.admin) {
        context.go('/login');
        return;
      }

      final productProvider = context.read<ProductProvider>();
      productProvider.loadProducts(reset: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final productProvider = context.read<ProductProvider>();
    productProvider.setSearchQuery(_searchController.text);
  }

  void _onCategoryChanged(String category) {
    final productProvider = context.read<ProductProvider>();
    productProvider.setSelectedCategory(category);
  }

  Future<void> _onAddToCart(Product product, int quantity) async {
    final cartProvider = context.read<CartProvider>();
    await cartProvider.addItem(product, quantity: quantity);

    Fluttertoast.showToast(
      msg: '${product.nome} adicionado ao carrinho!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isLoggedIn) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Catálogo de Produtos'),
            backgroundColor: Color.fromARGB(255, 245, 146, 16),
            foregroundColor: Colors.white,
            actions: [
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () => context.go('/cart'),
                      ),
                      if (cartProvider.itemCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${cartProvider.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          drawer: const AppDrawer(),
          body: Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              if (productProvider.isLoading &&
                  productProvider.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  // Search and Filter Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey.shade50,
                    child: Column(
                      children: [
                        // Search Bar
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Buscar produtos...',
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                onSubmitted: (_) => _onSearch(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _onSearch,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                  255,
                                  245,
                                  146,
                                  16,
                                ),
                                padding: const EdgeInsets.all(16),
                              ),
                              child: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Category Filter
                        // if (productProvider.categories.isNotEmpty)
                        //   SingleChildScrollView(
                        //     scrollDirection: Axis.horizontal,
                        //     child: Row(
                        //       children: [
                        //         _buildCategoryChip(
                        //           'Todos',
                        //           'all',
                        //           productProvider.selectedCategory,
                        //         ),
                        //         ...productProvider.categories.map(
                        //           (category) => _buildCategoryChip(
                        //             '${category.nome} (${category.quantidade})',
                        //             category.nome,
                        //             productProvider.selectedCategory,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                      ],
                    ),
                  ),

                  // Products Grid
                  Expanded(
                    child: productProvider.products.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Nenhum produto encontrado',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.7,
                                ),
                            itemCount:
                                productProvider.products.length +
                                (productProvider.isLoading ? 2 : 0),
                            itemBuilder: (context, index) {
                              if (index >= productProvider.products.length) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final product = productProvider.products[index];
                              return ProductCardAdmin(
                                product: product,
                                onAddToCart: (quantity) =>
                                    _onAddToCart(product, quantity),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(
    String label,
    String value,
    String selectedCategory,
  ) {
    final isSelected = selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            _onCategoryChanged(value);
          }
        },
        selectedColor: Colors.blue.withOpacity(0.2),
        checkmarkColor: Colors.blue,
      ),
    );
  }
}
