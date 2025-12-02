class CartItem {
  final String productId;
  final String productName;
  final String price;
  // imagem armazenada como URL/path string
  final String? image;
  final int quantity;

  const CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    this.image,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // aceitar diferentes formatos (frontend local, backend em português, ou produto embutido)
    String? productId = (json['productId'] ?? json['produtoId'])?.toString();
    String? productName =
        (json['productName'] ??
                json['produtoNome'] ??
                json['produto']?['nome'] ??
                json['produto']?['name'])
            ?.toString();

    // preço pode vir como string, número ou campo preco/precoUnitario
    String priceStr = '';
    if (json['price'] != null) {
      priceStr = json['price'].toString();
    } else if (json['precoUnitario'] != null) {
      priceStr = (json['precoUnitario'] as num).toString();
    } else if (json['preco'] != null) {
      priceStr = json['preco'].toString();
    } else if (json['produto'] is Map && json['produto']['preco'] != null) {
      priceStr = json['produto']['preco'].toString();
    }

    final image =
        (json['image'] ?? json['imagem'] ?? json['produto']?['imagem'])
            as String?;
    final quantidade = (json['quantity'] ?? json['quantidade']) is int
        ? (json['quantity'] ?? json['quantidade']) as int
        : int.tryParse(
                (json['quantity'] ?? json['quantidade'])?.toString() ?? '0',
              ) ??
              0;

    // Se productId ainda nulo, tentar extrair do objeto produto
    if (productId == null && json['produto'] is Map) {
      productId = (json['produto']['_id'] ?? json['produto']['id'])?.toString();
    }

    return CartItem(
      productId: productId ?? '',
      productName: productName ?? '',
      price: priceStr,
      image: image,
      quantity: quantidade,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'image': image,
      'quantity': quantity,
    };
  }

  /// Formato usado para enviar ao backend (compatível com o modelo C#).
  Map<String, dynamic> toBackendJson() {
    final unit = double.tryParse(price) ?? 0.0;
    return {
      'produtoId': productId,
      'quantidade': quantity,
      'precoUnitario': unit,
      'produto': {
        '_id': productId,
        'nome': productName,
        'preco': unit,
        if (image != null) 'imagem': image,
      },
    };
  }

  CartItem copyWith({
    String? productId,
    String? productName,
    String? price,
    String? image,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice {
    final unitPrice = double.tryParse(price) ?? 0.0;
    return unitPrice * quantity;
  }
}

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? deliveryAddress;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.deliveryAddress,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['userId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['status'] as String).toUpperCase(),
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      deliveryAddress: json['deliveryAddress'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.name.toUpperCase(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deliveryAddress': deliveryAddress,
    };
  }
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  delivering,
  delivered,
  cancelled,
}
