import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _dentistIdKey = 'dentist_id';

  // ─── Token Management ──────────────────────────────────────────────

  /// Saves both JWT tokens after a successful login or refresh.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _dentistIdKey);
  }

  // ─── Dentist ID (cached from /auth/me after login) ─────────────────

  Future<void> saveDentistId(String dentistId) async {
    await _storage.write(key: _dentistIdKey, value: dentistId);
  }

  Future<String?> getDentistId() async {
    return _storage.read(key: _dentistIdKey);
  }

  // ─── Session Check ─────────────────────────────────────────────────

  /// Returns true when the user has a stored access token (may need refresh).
  Future<bool> hasSession() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null;
  }

  // ─── Legacy alias (kept for router compatibility) ──────────────────

  /// @deprecated Use [hasSession] + [saveDentistId] instead.
  Future<void> saveSession(String dentistId) async {
    await saveDentistId(dentistId);
  }

  /// @deprecated Use [getDentistId] instead.
  Future<String?> getSession() async {
    return getDentistId();
  }

  /// @deprecated Use [clearTokens] instead.
  Future<void> clearSession() async {
    await clearTokens();
  }
}

// Provider for the secure storage service
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage());
});

