class Entregador {
  final String? id;
  final String nome;
  final String email;
  final String cnh;
  final bool disponivel;

  Entregador({
    this.id,
    required this.nome,
    required this.email,
    required this.cnh,
    required this.disponivel,
  });

  factory Entregador.fromJson(Map<String, dynamic> json) {
    return Entregador(
      id: json['id'] ?? json['_id'],
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      cnh: json['cnh'] ?? '',
      disponivel: json['disponivel'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'email': email,
      'cnh': cnh,
      'disponivel': disponivel,
    };
  }

  Entregador copyWith({
    String? id,
    String? nome,
    String? email,
    String? cnh,
    bool? disponivel,
  }) {
    return Entregador(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      cnh: cnh ?? this.cnh,
      disponivel: disponivel ?? this.disponivel,
    );
  }
}
