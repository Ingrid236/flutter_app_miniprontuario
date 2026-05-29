import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../domain/procedure.dart';

abstract class ProcedureRepository {
  Future<void> createProcedure(Procedure procedure);
  Future<void> updateProcedure(Procedure procedure);
  Future<void> deleteProcedure(String id);
  Future<Procedure?> getProcedureById(String id);
  Future<List<Procedure>> getProceduresForPatient(String patientId);
}

class SqliteProcedureRepository implements ProcedureRepository {
  final DatabaseHelper _databaseHelper;

  SqliteProcedureRepository(this._databaseHelper);

  @override
  Future<void> createProcedure(Procedure procedure) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'procedures',
      procedure.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  @override
  Future<void> updateProcedure(Procedure procedure) async {
    final db = await _databaseHelper.database;
    await db.update(
      'procedures',
      procedure.toMap(),
      where: 'id = ?',
      whereArgs: [procedure.id],
    );
  }

  @override
  Future<void> deleteProcedure(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('procedures', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Procedure?> getProcedureById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'procedures',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Procedure.fromMap(maps.first);
  }

  @override
  Future<List<Procedure>> getProceduresForPatient(String patientId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'procedures',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'date DESC', // Sort reverse chronologically
    );
    return maps.map((map) => Procedure.fromMap(map)).toList();
  }
}

// Provider for ProcedureRepository
final procedureRepositoryProvider = Provider<ProcedureRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return SqliteProcedureRepository(dbHelper);
});
