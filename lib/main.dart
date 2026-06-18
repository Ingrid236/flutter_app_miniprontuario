import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/shared_preferences_provider.dart';
import 'features/auth/presentation/auth_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Triggers session check on app startup
    ref.watch(sessionCheckProvider);

    final router = ref.watch(appRouterHelperProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'MiniProntuário Odontológico',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate 50
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0891B2), // Cyan 600
          secondary: Color(0xFF2563EB), // Blue 600
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A), // Slate 900
          ),
          bodyMedium: TextStyle(color: Color(0xFF334155)), // Slate 700
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8FAFC),
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
          iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF06B6D4), // Cyan 500
          secondary: Color(0xFF3B82F6), // Blue 500
          surface: Color(0xFF1E293B), // Slate 800
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(color: Color(0xFFE2E8F0)), // Slate 200
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      routerConfig: router,
    );
  }
}
