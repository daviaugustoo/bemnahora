import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';
import '../providers/cartProvider.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final Function(int quantity)? onAddToCart;

  const ProductCard({super.key, required this.product, this.onAddToCart});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                color: Colors.grey,
              ),
            ),
          ),

          // Product Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Category
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.nome,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.product.categoria,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Price and Weight
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'R\$ ${widget.product.preco}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          if (widget.product.peso != null &&
                              widget.product.quantidadeEmEstoque != null)
                            Text(
                              '${widget.product.peso} ${widget.product.quantidadeEmEstoque}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        'Estoque: ${widget.product.quantidadeEmEstoque}',
                        style: TextStyle(
                          fontSize: 10,
                          color: widget.product.emEstoque
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Quantity Controls and Add to Cart
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Quantity Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                      icon: const Text(
                        '-',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _quantity < widget.product.quantidadeEmEstoque
                          ? () => setState(() => _quantity++)
                          : null,
                      icon: const Text(
                        '+',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Add to Cart Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (widget.onAddToCart != null) {
                        widget.onAddToCart!(_quantity);
                      } else {
                        // Fallback: add directly to cart provider
                        final cartProvider = context.read<CartProvider>();
                        cartProvider.addItem(
                          widget.product,
                          quantity: _quantity,
                        );
                      }
                    },
                    icon: const Icon(Icons.add_shopping_cart, size: 16),
                    label: const Text(
                      'Adicionar',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 245, 146, 16),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(12),
          //   child: Container(
          //     width: double.infinity,
          //     padding: const EdgeInsets.symmetric(vertical: 8),
          //     decoration: BoxDecoration(
          //       color: Colors.red.shade100,
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: const Text(
          //       'Fora de estoque',
          //       textAlign: TextAlign.center,
          //       style: TextStyle(
          //         color: Colors.red,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
