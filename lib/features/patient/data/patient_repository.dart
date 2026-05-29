import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../domain/patient.dart';

abstract class PatientRepository {
  Future<void> createPatient(Patient patient);
  Future<void> updatePatient(Patient patient);
  Future<void> deletePatient(String id);
  Future<Patient?> getPatientById(String id);
  Future<List<Patient>> getPatientsForDentist(String dentistId);
  Future<Patient?> getPatientByCpf(String dentistId, String cpf);
  Future<List<Patient>> searchPatients(String dentistId, String query);
}

class SqlitePatientRepository implements PatientRepository {
  final DatabaseHelper _databaseHelper;

  SqlitePatientRepository(this._databaseHelper);

  @override
  Future<void> createPatient(Patient patient) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'patients',
      patient.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  @override
  Future<void> updatePatient(Patient patient) async {
    final db = await _databaseHelper.database;
    await db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  @override
  Future<void> deletePatient(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Patient?> getPatientById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Patient.fromMap(maps.first);
  }

  @override
  Future<List<Patient>> getPatientsForDentist(String dentistId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'dentist_id = ?',
      whereArgs: [dentistId],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  @override
  Future<Patient?> getPatientByCpf(String dentistId, String cpf) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'dentist_id = ? AND cpf = ?',
      whereArgs: [dentistId, cpf],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Patient.fromMap(maps.first);
  }

  @override
  Future<List<Patient>> searchPatients(String dentistId, String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'dentist_id = ? AND (name LIKE ? OR cpf LIKE ?)',
      whereArgs: [dentistId, '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Patient.fromMap(map)).toList();
  }
}

// Provider for PatientRepository
final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return SqlitePatientRepository(dbHelper);
});
