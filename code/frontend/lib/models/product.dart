class Product {
  final String id;
  final String nome;
  final String? descricao;
  final String preco;
  // imagem agora armazena uma URL ou caminho como String (null se não houver)
  final String? imagem;
  final String categoria;
  final String? peso;
  final String? unidade;
  final int quantidadeEmEstoque;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.nome,
    this.descricao,
    required this.preco,
    this.imagem,
    required this.categoria,
    this.peso,
    this.unidade,
    required this.quantidadeEmEstoque,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // tenta ler tanto "id" quanto "_id" (MongoDB comum no backend)
    final id = (json['_id'] ?? json['id'] ?? '') as String;

    // imagem normalmente vem como URL em string; aceitar campos comuns
    final imagemUrl =
        (json['imagemUrl'] ?? json['imagem'] ?? json['image']) as String?;

    // quantidade pode vir como int ou string
    int quantidade = 0;
    try {
      if (json['quantidadeEmEstoque'] is int) {
        quantidade = json['quantidadeEmEstoque'] as int;
      } else if (json['quantidadeEmEstoque'] != null) {
        quantidade = int.tryParse(json['quantidadeEmEstoque'].toString()) ?? 0;
      }
    } catch (_) {
      quantidade = 0;
    }

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return null;
      }
    }

    return Product(
      id: id,
      nome: (json['nome'] ?? '') as String,
      descricao: json['descricao'] as String?,
      preco: (json['preco'] ?? '').toString(),
      imagem: imagemUrl,
      categoria: (json['categoria'] ?? '') as String,
      peso: json['peso'] as String?,
      unidade: json['unidade'] as String?,
      quantidadeEmEstoque: quantidade,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      // enviar imagem como string (url ou path) quando disponível
      'imagem': imagem,
      'categoria': categoria,
      'peso': peso,
      'unidade': unidade,
      'quantidadeEmEstoque': quantidadeEmEstoque,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  double get precoAsDouble => double.tryParse(preco) ?? 0.0;

  bool get emEstoque => quantidadeEmEstoque > 0;
}
