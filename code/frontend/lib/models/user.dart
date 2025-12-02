class User {
  final String id;
  final String username;
  final String? nome;
  final String? nomeCompleto;
  final String? nomeFantasia;
  final String? imagem; // URL da imagem
  final String? endereco;
  final String? cidade;
  final String? estado;
  final String? passwordHash;
  final String? telefone;
  final UserType role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.username,
    this.nome,
    this.nomeCompleto,
    this.nomeFantasia,
    this.imagem,
    this.endereco,
    this.cidade,
    this.estado,
    this.passwordHash,
    this.telefone,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final dynamic idValue =
        json['id'] ?? json['_id'] ?? json['Id'] ?? json['ID'];
    final id = _extractId(idValue) ?? '';

    final username = _normalizeString(
          json['username'] ??
              json['Username'] ??
              json['email'] ??
              json['Email'],
        ) ??
        '';

    final roleRaw =
        json['role'] ?? json['tipoUsuario'] ?? json['tipo'] ?? json['userType'];

    DateTime? tryParseDate(dynamic value) {
      if (value == null) return null;
      final text = value.toString();
      if (text.isEmpty) return null;
      return DateTime.tryParse(text);
    }

    return User(
      id: id,
      username: username,
      nome: _normalizeString(json['nome'] ?? json['name']),
      nomeCompleto: _normalizeString(
        json['nomeCompleto'] ?? json['fullName'] ?? json['nomeFantasia'],
      ),
      nomeFantasia: _normalizeString(json['nomeFantasia']),
      imagem: _normalizeString(json['imagem'] ?? json['imageUrl']),
      endereco: _normalizeString(json['endereco'] ?? json['enderecoPrincipal']),
      cidade: _normalizeString(json['cidade'] ?? json['city']),
      estado: _normalizeString(json['estado'] ?? json['state']),
      passwordHash:
          _normalizeString(json['passwordHash'] ?? json['senha']),
      telefone: _normalizeString(
        json['telefone'] ?? json['phone'] ?? json['celular'],
      ),
      role: UserTypeExtension.fromRole(_normalizeString(roleRaw)),
      createdAt: tryParseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: tryParseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nome': nome,
      'nomeCompleto': nomeCompleto,
      'imagem': imagem,
      'endereco': endereco,
      'cidade': cidade,
      'estado': estado,
      'passwordHash': passwordHash,
      'telefone': telefone,
      'role': role.name,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Use este para cadastro (não envia id e converte role)
  Map<String, dynamic> toCreateJson() {
    return {
      'username': username,
      'nome': nome,
      'nomeCompleto': nomeCompleto ?? nomeFantasia,
      'nomeFantasia': nomeFantasia,
      'imagem': imagem,
      'endereco': endereco,
      'cidade': cidade,
      'estado': estado,
      'passwordHash': passwordHash, // senha em claro; backend deve hashear
      'telefone': telefone,
      'role': _roleBackend(role),
    };
  }

  static String _roleBackend(UserType role) {
    switch (role) {
      case UserType.admin:
        return 'distribuidora'; // "Empresa" no form
      case UserType.deliverer:
        return 'entregador';
      case UserType.customer:
        return 'consumidor';
    }
  }

  User copyWith({
    String? id,
    String? username,
    String? nome,
    String? nomeCompleto,
    String? nomeFantasia,
    String? imagem,
    String? endereco,
    String? cidade,
    String? estado,
    String? passwordHash,
    String? telefone,
    UserType? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      nome: nome ?? this.nome,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      nomeFantasia: nomeFantasia ?? this.nomeFantasia,
      imagem: imagem ?? this.imagem,
      endereco: endereco ?? this.endereco,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      passwordHash: passwordHash ?? this.passwordHash,
      telefone: telefone ?? this.telefone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayName => nomeCompleto ?? nomeFantasia ?? nome ?? username;
}

enum UserType { admin, customer, deliverer }

extension UserTypeExtension on UserType {
  static UserType fromRole(String? role) {
    final normalized = role?.toLowerCase().trim();
    if (normalized == null || normalized.isEmpty) {
      return UserType.customer;
    }

    if (normalized == 'admin' ||
        normalized == 'distribuidora' ||
        normalized == 'empresa') {
      return UserType.admin;
    }

    if (normalized == 'deliverer' || normalized == 'entregador') {
      return UserType.deliverer;
    }

    if (normalized == 'customer' ||
        normalized == 'consumidor' ||
        normalized == 'cliente') {
      return UserType.customer;
    }

    return UserType.customer;
  }
}

String? _normalizeString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value.trim();
  if (value is num || value is bool) return value.toString();
  if (value is Map) {
    for (final key in ['value', 'text', 'descricao']) {
      if (value.containsKey(key)) {
        final nested = _normalizeString(value[key]);
        if (nested != null && nested.isNotEmpty) return nested;
      }
    }
  }
  final text = value.toString();
  return text.isEmpty ? null : text;
}

String? _extractId(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    final trimmed = value.trim();
    final match = _objectIdPattern.firstMatch(trimmed);
    return match?.group(1) ?? trimmed;
  }
  if (value is num || value is bool) {
    return value.toString();
  }
  if (value is Map) {
    for (final key in [
      'id',
      '_id',
      'Id',
      'ID',
      'value',
      'Value',
      r'$id',
      r'$Id',
      r'$ID',
      r'$value',
      r'$Value',
      r'$oid',
      'oid',
      'Oid',
      'OID',
      'ObjectId',
      'objectId',
    ]) {
      if (value.containsKey(key)) {
        final extracted = _extractId(value[key]);
        if (extracted != null && extracted.isNotEmpty) {
          return extracted;
        }
      }
    }
    for (final entry in value.entries) {
      final extracted = _extractId(entry.value);
      if (extracted != null && extracted.isNotEmpty) {
        return extracted;
      }
    }
  }
  final text = value.toString();
  final match = _objectIdPattern.firstMatch(text);
  return match?.group(1) ?? (text.isEmpty ? null : text);
}

final RegExp _objectIdPattern = RegExp(r'([a-fA-F0-9]{24})');
