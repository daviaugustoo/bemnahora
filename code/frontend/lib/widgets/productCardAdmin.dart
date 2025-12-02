import 'package:bem_na_hora_flutter/pages/updateProductPage.dart';
import 'package:bem_na_hora_flutter/providers/productProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';
import '../providers/cartProvider.dart';

class ProductCardAdmin extends StatefulWidget {
  final Product product;
  final Function(int quantity)? onAddToCart;

  const ProductCardAdmin({super.key, required this.product, this.onAddToCart});

  @override
  State<ProductCardAdmin> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCardAdmin> {
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

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              UpdateProductPage(productId: widget.product.id),
                        ),
                      );

                      if (result == true) {
                        context.read<ProductProvider>().loadProducts(
                          reset: true,
                        );
                      }
                    },

                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text("Editar", style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // DELETAR
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      bool confirmar = await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text("Excluir produto"),
                          content: Text(
                            "Tem certeza que deseja excluir este produto?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text("Excluir"),
                            ),
                          ],
                        ),
                      );

                      if (confirmar == true) {
                        final provider = context.read<ProductProvider>();
                        await provider.deleteProduct(widget.product.id);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Produto deletado com sucesso!"),
                          ),
                        );
                      }
                    },

                    icon: const Icon(Icons.delete_forever, size: 18),
                    label: const Text(
                      "Deletar",
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
