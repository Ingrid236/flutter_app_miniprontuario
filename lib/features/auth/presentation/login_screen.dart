import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

    if (success && mounted) {
      context.go('/');
    } else if (mounted) {
      final errorState = ref.read(authControllerProvider);
      final errorMsg = errorState.maybeWhen(
        error: (err, _) => err.toString().replaceAll('Exception: ', ''),
        orElse: () => 'Erro ao realizar login.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AsyncLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo/Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF06B6D4),
                      Color(0xFF3B82F6),
                    ], // Cyan to Blue
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF06B6D4).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  size: 44,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              // App Title
              const Text(
                'MiniProntuário',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Acesso para Profissionais de Odontologia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF94A3B8), // Slate 400
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),

              // Form Card
              Container(
                padding: const EdgeInsets.all(28.0),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF1E293B,
                  ).withOpacity(0.8), // Slate 800 with transparency
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(
                      0xFF334155,
                    ).withOpacity(0.5), // Slate 700
                    width: 1.5,
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email Field
                      const Text(
                        'E-mail',
                        style: TextStyle(
                          color: Color(0xFFCBD5E1), // Slate 300
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'exemplo@odontologia.com',
                          hintStyle: const TextStyle(color: Color(0xFF64748B)),
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFF64748B),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, insira seu e-mail';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value.trim())) {
                            return 'Insira um e-mail válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      const Text(
                        'Senha',
                        style: TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Sua senha segura',
                          hintStyle: const TextStyle(color: Color(0xFF64748B)),
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFF64748B),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira sua senha';
                          }
                          if (value.length < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style:
                            ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                            ).copyWith(
                              backgroundColor: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                if (states.contains(WidgetState.disabled)) {
                                  return const Color(0xFF334155);
                                }
                                return const Color(0xFF06B6D4);
                              }),
                            ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Não possui uma conta? ',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: const Text(
                      'Cadastre-se',
                      style: TextStyle(
                        color: Color(0xFF06B6D4),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
