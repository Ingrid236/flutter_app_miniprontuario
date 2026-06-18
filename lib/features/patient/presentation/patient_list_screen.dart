import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_providers.dart';
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
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Sair', style: TextStyle(color: Colors.white)),
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

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Professional Profile Header
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B), // Slate 800
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
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
                          color: const Color(0xFF06B6D4).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF06B6D4),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF06B6D4),
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
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'CRO: ${dentist.cro ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF94A3B8), // Slate 400
                              ),
                            ),
                          ],
                        ),
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
                  const Text(
                    'Pacientes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome ou CPF...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF64748B),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Color(0xFF64748B),
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
                        borderSide: const BorderSide(
                          color: Color(0xFF06B6D4),
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
                            color: const Color(0xFF475569).withOpacity(0.8),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhum paciente encontrado',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF64748B),
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
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF334155).withOpacity(0.3),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          title: Text(
                            patient.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.badge_outlined,
                                  size: 14,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  patient.cpf,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.phone_outlined,
                                  size: 14,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                   patient.phone ?? 'Não informado',
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF06B6D4),
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
        backgroundColor: const Color(0xFF06B6D4),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
