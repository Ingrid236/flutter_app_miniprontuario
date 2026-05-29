class Dentist {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final String cpf;
  final String cro;
  final String phone;
  final DateTime createdAt;

  const Dentist({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.cpf,
    required this.cro,
    required this.phone,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'cpf': cpf,
      'cro': cro,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Dentist.fromMap(Map<String, dynamic> map) {
    return Dentist(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      cpf: map['cpf'] as String,
      cro: map['cro'] as String,
      phone: map['phone'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Dentist copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
    String? cpf,
    String? cro,
    String? phone,
    DateTime? createdAt,
  }) {
    return Dentist(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      cpf: cpf ?? this.cpf,
      cro: cro ?? this.cro,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
