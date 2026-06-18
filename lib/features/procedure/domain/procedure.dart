/// Procedure domain model — maps to the backend's ProcedureResponse DTO.
///
/// Backend fields: id, patientId, date (LocalDate), description, tooth, notes,
/// createdAt, updatedAt.
///
/// Note: The old local model had different fields (type, status, cost, observations).
/// These have been mapped to the backend contract:
///   - type/description → description
///   - observations → notes
///   - status and cost are not in the backend schema
class Procedure {
  final String id;
  final String patientId;
  final DateTime date;
  final String description;
  final String? tooth;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Procedure({
    required this.id,
    required this.patientId,
    required this.date,
    required this.description,
    this.tooth,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Procedure.fromJson(Map<String, dynamic> json) {
    return Procedure(
      id: json['id'].toString(),
      patientId: json['patientId'].toString(),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      tooth: json['tooth'] as String?,
      notes: json['notes'] as String?,
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
      'date': '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}',
      'description': description,
      if (tooth != null) 'tooth': tooth,
      if (notes != null) 'notes': notes,
    };
  }

  Procedure copyWith({
    String? id,
    String? patientId,
    DateTime? date,
    String? description,
    String? tooth,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Procedure(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      date: date ?? this.date,
      description: description ?? this.description,
      tooth: tooth ?? this.tooth,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
