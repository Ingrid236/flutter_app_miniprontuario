class Procedure {
  final String id;
  final String patientId;
  final String type;
  final DateTime date;
  final String? tooth;
  final String? observations;
  final String status;
  final double? cost;
  final DateTime createdAt;

  const Procedure({
    required this.id,
    required this.patientId,
    required this.type,
    required this.date,
    this.tooth,
    this.observations,
    required this.status,
    this.cost,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T').first,
      'description': type,
      'tooth': tooth,
      'notes': observations,
      'status': status,
      'cost': cost,
    };
  }

  factory Procedure.fromMap(Map<String, dynamic> map) {
    return Procedure(
      id: map['id'] as String,
      patientId: (map['patientId'] ?? map['patient_id'] ?? '') as String,
      type: (map['description'] ?? map['type'] ?? '') as String,
      date: DateTime.parse(map['date'] as String),
      tooth: map['tooth'] as String?,
      observations: (map['notes'] ?? map['observations']) as String?,
      status: (map['status'] ?? 'PLANNED') as String,
      cost: map['cost'] != null ? (map['cost'] as num).toDouble() : null,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : (map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now()),
    );
  }

  Procedure copyWith({
    String? id,
    String? patientId,
    String? type,
    DateTime? date,
    String? tooth,
    String? observations,
    String? status,
    double? cost,
    DateTime? createdAt,
  }) {
    return Procedure(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      type: type ?? this.type,
      date: date ?? this.date,
      tooth: tooth ?? this.tooth,
      observations: observations ?? this.observations,
      status: status ?? this.status,
      cost: cost ?? this.cost,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
