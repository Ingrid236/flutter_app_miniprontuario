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
      'patient_id': patientId,
      'type': type,
      'date': date.toIso8601String(),
      'tooth': tooth,
      'observations': observations,
      'status': status,
      'cost': cost,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Procedure.fromMap(Map<String, dynamic> map) {
    return Procedure(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      type: map['type'] as String,
      date: DateTime.parse(map['date'] as String),
      tooth: map['tooth'] as String?,
      observations: map['observations'] as String?,
      status: map['status'] as String,
      cost: map['cost'] != null ? (map['cost'] as num).toDouble() : null,
      createdAt: DateTime.parse(map['created_at'] as String),
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
