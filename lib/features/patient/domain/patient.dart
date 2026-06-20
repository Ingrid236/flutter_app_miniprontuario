/// Patient domain model — maps to the backend's PatientResponse DTO.
class Patient {
  final String id;
  final String name;
  final DateTime birthDate;
  final String cpf;
  final String? phone;
  final String? allergies;
  /// Maps to `systemicDiseases` in the backend (formerly `chronicDiseases`).
  final String? systemicDiseases;
  final String? medications;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Patient({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.cpf,
    this.phone,
    this.allergies,
    this.systemicDiseases,
    this.medications,
    this.createdAt,
    this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'].toString(),
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      cpf: json['cpf'] as String,
      phone: json['phone'] as String?,
      allergies: json['allergies'] as String?,
      systemicDiseases: json['systemicDiseases'] as String?,
      medications: json['medications'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cpf': cpf,
      'birthDate': '${birthDate.year.toString().padLeft(4, '0')}-'
          '${birthDate.month.toString().padLeft(2, '0')}-'
          '${birthDate.day.toString().padLeft(2, '0')}',
      if (phone != null) 'phone': phone,
      if (allergies != null) 'allergies': allergies,
      if (systemicDiseases != null) 'systemicDiseases': systemicDiseases,
      if (medications != null) 'medications': medications,
    };
  }

  Patient copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    String? cpf,
    String? phone,
    String? allergies,
    String? systemicDiseases,
    String? medications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      cpf: cpf ?? this.cpf,
      phone: phone ?? this.phone,
      allergies: allergies ?? this.allergies,
      systemicDiseases: systemicDiseases ?? this.systemicDiseases,
      medications: medications ?? this.medications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


