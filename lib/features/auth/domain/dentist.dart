/// Represents the authenticated dentist (maps to backend MeResponse).
class Dentist {
  final String id;
  final String name;
  final String email;
  final String? cpf;
  final String? cro;
  final String? phone;

  Dentist({
    required this.id,
    required this.name,
    required this.email,
    this.cpf,
    this.cro,
    this.phone,
  });

  factory Dentist.fromJson(Map<String, dynamic> json) {
    return Dentist(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      cpf: json['cpf'] as String?,
      cro: json['cro'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (cpf != null) 'cpf': cpf,
      if (cro != null) 'cro': cro,
      if (phone != null) 'phone': phone,
    };
  }

  Dentist copyWith({
    String? id,
    String? name,
    String? email,
    String? cpf,
    String? cro,
    String? phone,
  }) {
    return Dentist(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      cro: cro ?? this.cro,
      phone: phone ?? this.phone,
    );
  }
}

