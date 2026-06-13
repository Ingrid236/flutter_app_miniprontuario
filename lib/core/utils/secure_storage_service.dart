import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  static const String _dbKeyName = 'db_encryption_key';
  static const String _sessionKeyName = 'active_dentist_id';

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Retrieves the existing database encryption key, or creates a new one
  /// if it does not exist.
  Future<String> getOrCreateDatabaseKey() async {
    String? key = await _storage.read(key: _dbKeyName);
    if (key == null) {
      key = _generateSecureKey();
      await _storage.write(key: _dbKeyName, value: key);
    }
    return key;
  }

  /// Saves the active dentist session (ID) and tokens.
  Future<void> saveSession(String dentistId) async {
    await _storage.write(key: _sessionKeyName, value: dentistId);
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Retrieves the active dentist ID if a session is present.
  Future<String?> getSession() async {
    return await _storage.read(key: _sessionKeyName);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Clears the active dentist session and tokens.
  Future<void> clearSession() async {
    await _storage.delete(key: _sessionKeyName);
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Helper to generate a random cryptographically secure string key
  String _generateSecureKey() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }
}

// Provider for the secure storage service
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage());
});
