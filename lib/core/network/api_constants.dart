import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Base URL for the MiniProntuário backend API.
///
/// Automatically adjusts based on the platform:
/// - Web / iOS / Windows: `http://localhost:8080`
/// - Android emulator: `http://10.0.2.2:8080`
class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    try {
      if (Platform.isAndroid) {
        // Se estiver no Emulador Android: usar 'http://10.0.2.2:8080'
        // Se estiver em um celular físico: usar o IP atual do seu computador na rede (ex: 'http://10.219.115.126:8080')
        // Ou rodar o comando 'adb reverse tcp:8080 tcp:8080' no seu terminal e usar 'http://localhost:8080'
        return 'http://10.0.2.2:8080';
      }
      if (Platform.isIOS) {
        return 'http://localhost:8080';
      }
    } catch (_) {}
    return 'http://localhost:8080';
  }

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Patients
  static const String patients = '/patients';
  static String patient(String id) => '/patients/$id';

  // Procedures
  static String proceduresForPatient(String patientId) =>
      '/patients/$patientId/procedures';
  static String procedure(String id) => '/procedures/$id';
}
