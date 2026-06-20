import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/registration_screen.dart';
import '../../features/patient/presentation/patient_detail_screen.dart';
import '../../features/patient/presentation/patient_form_screen.dart';
import '../../features/patient/presentation/patient_list_screen.dart';
import '../../features/procedure/presentation/procedure_form_screen.dart';

final appRouterHelperProvider = Provider<GoRouter>((ref) {
  // We watch the dentist ID provider to trigger route evaluation when authentication state changes.
  final activeDentistId = ref.watch(activeDentistIdProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';

      final isLoggedIn = activeDentistId != null;

      if (!isLoggedIn) {
        // If not logged in and not trying to login/register, force redirect to /login
        if (!isLoggingIn && !isRegistering) {
          return '/login';
        }
      } else {
        // If logged in and on /login or /register, redirect to patients dashboard
        if (isLoggingIn || isRegistering) {
          return '/';
        }
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const PatientListScreen(),
        routes: [
          GoRoute(
            path: 'patients/new',
            builder: (context, state) => const PatientFormScreen(),
          ),
          GoRoute(
            path: 'patients/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return PatientDetailScreen(patientId: id);
            },
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PatientFormScreen(patientId: id);
                },
              ),
              GoRoute(
                path: 'procedures/new',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ProcedureFormScreen(patientId: id);
                },
              ),
              GoRoute(
                path: 'procedures/:procId/edit',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final procId = state.pathParameters['procId']!;
                  return ProcedureFormScreen(
                    patientId: id,
                    procedureId: procId,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
