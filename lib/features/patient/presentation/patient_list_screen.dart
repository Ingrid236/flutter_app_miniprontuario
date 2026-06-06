import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../../core/theme/theme_provider.dart';
import 'patient_providers.dart';

class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({super.key});

  @override
  ConsumerState<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(patientsListProvider.notifier).search(query);
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Deseja realmente sair da sua conta profissional?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(authControllerProvider.notifier).logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dentistAsync = ref.watch(currentDentistProvider);
    final patientsAsync = ref.watch(patientsListProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Professional Profile Header
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: dentistAsync.when(
                data: (dentist) {
                  if (dentist == null) return const SizedBox();
                  return Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dentist.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'CRO: ${dentist.cro}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<ThemeMode>(
                        icon: Icon(
                          themeMode == ThemeMode.system
                              ? Icons.brightness_auto
                              : themeMode == ThemeMode.light
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        tooltip: 'Alterar Tema',
                        onSelected: (mode) {
                          ref.read(themeProvider.notifier).setThemeMode(mode);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: ThemeMode.system,
                            child: Row(
                              children: [
                                Icon(Icons.brightness_auto),
                                SizedBox(width: 8),
                                Text('Sistema'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: ThemeMode.light,
                            child: Row(
                              children: [
                                Icon(Icons.light_mode),
                                SizedBox(width: 8),
                                Text('Claro'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: ThemeMode.dark,
                            child: Row(
                              children: [
                                Icon(Icons.dark_mode),
                                SizedBox(width: 8),
                                Text('Escuro'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout_outlined,
                          color: Colors.redAccent,
                        ),
                        onPressed: _logout,
                        tooltip: 'Sair',
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (err, _) =>
                    Text('Erro ao carregar dados do profissional: $err'),
              ),
            ),

            const SizedBox(height: 20),

            // Search Bar & Filter Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pacientes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome ou CPF...',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                                setState(() {});
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Patient List
            Expanded(
              child: patientsAsync.when(
                data: (patients) {
                  if (patients.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum paciente encontrado',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final patient = patients[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          title: Text(
                            patient.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.badge_outlined,
                                    size: 14,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    patient.cpf,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 14,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    patient.phone,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onTap: () => context.push('/patients/${patient.id}'),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Erro ao carregar pacientes: $err',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/patients/new'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
