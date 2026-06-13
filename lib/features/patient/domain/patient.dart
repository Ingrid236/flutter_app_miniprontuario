class Patient {
  final String id;
  final String dentistId;
  final String name;
  final DateTime birthDate;
  final String cpf;
  final String phone;
  final String? allergies;
  final String? medications;
  final String? chronicDiseases;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Patient({
    required this.id,
    required this.dentistId,
    required this.name,
    required this.birthDate,
    required this.cpf,
    required this.phone,
    this.allergies,
    this.medications,
    this.chronicDiseases,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String().split('T').first,
      'cpf': cpf,
      'phone': phone,
      'allergies': allergies,
      'medications': medications,
      'systemicDiseases': chronicDiseases,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as String,
      dentistId: (map['dentist_id'] ?? '') as String,
      name: map['name'] as String,
      birthDate: DateTime.parse(map['birthDate'] ?? map['birth_date'] as String),
      cpf: map['cpf'] as String,
      phone: (map['phone'] ?? '') as String,
      allergies: map['allergies'] as String?,
      medications: map['medications'] as String?,
      chronicDiseases: (map['systemicDiseases'] ?? map['chronic_diseases']) as String?,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'] as String)
          : (map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now()),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : (map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : DateTime.now()),
    );
  }

  Patient copyWith({
    String? id,
    String? dentistId,
    String? name,
    DateTime? birthDate,
    String? cpf,
    String? phone,
    String? allergies,
    String? medications,
    String? chronicDiseases,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      dentistId: dentistId ?? this.dentistId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      cpf: cpf ?? this.cpf,
      phone: phone ?? this.phone,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
