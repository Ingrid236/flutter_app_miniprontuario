import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/secure_storage_service.dart';
import '../data/auth_repository.dart';
import 'dentist.dart';

class AuthService {
  final AuthRepository _authRepository;
  final SecureStorageService _secureStorage;
  static const _uuid = Uuid();

  AuthService(this._authRepository, this._secureStorage);

  Future<Dentist?> register({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String cro,
    required String phone,
  }) async {
    final existing = await _authRepository.getDentistByEmail(email);
    if (existing != null) {
      throw Exception('Dentist with email $email already exists');
    }

    final id = _uuid.v4();
    final passwordHash = _hashPassword(password);
    final dentist = Dentist(
      id: id,
      name: name,
      email: email,
      passwordHash: passwordHash,
      cpf: cpf,
      cro: cro,
      phone: phone,
      createdAt: DateTime.now(),
    );

    await _authRepository.createDentist(dentist);
    await _secureStorage.saveSession(dentist.id);
    return dentist;
  }

  Future<Dentist?> login({
    required String email,
    required String password,
  }) async {
    final dentist = await _authRepository.getDentistByEmail(email);
    if (dentist == null) return null;

    final hash = _hashPassword(password);
    if (dentist.passwordHash == hash) {
      await _secureStorage.saveSession(dentist.id);
      return dentist;
    }
    return null;
  }

  Future<void> logout() async {
    await _secureStorage.clearSession();
  }

  Future<Dentist?> getCurrentDentist() async {
    final dentistId = await _secureStorage.getSession();
    if (dentistId == null) return null;
    return await _authRepository.getDentistById(dentistId);
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
