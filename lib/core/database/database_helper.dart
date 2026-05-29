import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/secure_storage_service.dart';

class DatabaseHelper {
  final SecureStorageService _secureStorage;
  Database? _database;

  DatabaseHelper(this._secureStorage);

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final password = await _secureStorage.getOrCreateDatabaseKey();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'miniprontuario.db');

    return await openDatabase(
      path,
      version: 1,
      password: password,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create dentists table
    await db.execute('''
      CREATE TABLE dentists (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        cpf TEXT NOT NULL UNIQUE,
        cro TEXT NOT NULL,
        phone TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create patients table
    await db.execute('''
      CREATE TABLE patients (
        id TEXT PRIMARY KEY,
        dentist_id TEXT NOT NULL,
        name TEXT NOT NULL,
        birth_date TEXT NOT NULL,
        cpf TEXT NOT NULL,
        phone TEXT NOT NULL,
        allergies TEXT,
        medications TEXT,
        chronic_diseases TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(dentist_id, cpf),
        FOREIGN KEY(dentist_id) REFERENCES dentists(id) ON DELETE CASCADE
      )
    ''');

    // Create procedures table
    await db.execute('''
      CREATE TABLE procedures (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        tooth TEXT,
        observations TEXT,
        status TEXT NOT NULL,
        cost REAL,
        created_at TEXT NOT NULL,
        FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE CASCADE
      )
    ''');
  }

  /// Helper to delete the database (useful for testing or resetting the app)
  @visibleForTesting
  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'miniprontuario.db');
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    await deleteDatabase(path);
  }
}

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return DatabaseHelper(secureStorage);
});
