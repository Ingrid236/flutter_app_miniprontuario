import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app_miniprontuario/core/utils/shared_preferences_provider.dart';
import 'package:flutter_app_miniprontuario/core/utils/secure_storage_service.dart';
import 'package:flutter_app_miniprontuario/features/auth/data/auth_repository.dart';
import 'package:flutter_app_miniprontuario/main.dart';
import 'features/auth/auth_service_test.dart';

void main() {
  testWidgets('App loads and renders Login Screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    final fakeSecureStorage = FakeSecureStorageService();
    final fakeAuthRepository = FakeAuthRepository();

    // Build our app and trigger a frame with mocked providers.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          secureStorageProvider.overrideWithValue(fakeSecureStorage),
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that the title and login controls are displayed
    expect(find.text('MiniProntuário'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
