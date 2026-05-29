import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../domain/dentist.dart';

abstract class AuthRepository {
  Future<void> createDentist(Dentist dentist);
  Future<Dentist?> getDentistByEmail(String email);
  Future<Dentist?> getDentistById(String id);
}

class SqliteAuthRepository implements AuthRepository {
  final DatabaseHelper _databaseHelper;

  SqliteAuthRepository(this._databaseHelper);

  @override
  Future<void> createDentist(Dentist dentist) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'dentists',
      dentist.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  @override
  Future<Dentist?> getDentistByEmail(String email) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dentists',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Dentist.fromMap(maps.first);
  }

  @override
  Future<Dentist?> getDentistById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dentists',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Dentist.fromMap(maps.first);
  }
}

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return SqliteAuthRepository(dbHelper);
});
