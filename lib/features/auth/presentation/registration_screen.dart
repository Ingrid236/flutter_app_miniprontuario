import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_providers.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cpfController = TextEditingController();
  final _croController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cpfController.dispose();
    _croController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          cpf: _cpfController.text.trim(),
          cro: _croController.text.trim(),
          phone: _phoneController.text.trim(),
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta profissional criada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/');
    } else if (mounted) {
      final errorState = ref.read(authControllerProvider);
      final errorMsg = errorState.maybeWhen(
        error: (err, _) => err.toString().replaceAll('Exception: ', ''),
        orElse: () => 'Erro ao registrar profissional.',
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Criar Conta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cadastre seus dados profissionais para começar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF94A3B8), // Slate 400
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // Registration Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF334155).withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Full Name
                      _buildLabel('Nome Completo'),
                      _buildTextField(
                        controller: _nameController,
                        hint: 'Dr(a). Nome Sobrenome',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Insira seu nome completo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email
                      _buildLabel('E-mail'),
                      _buildTextField(
                        controller: _emailController,
                        hint: 'exemplo@odontologia.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Insira seu e-mail';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value.trim())) {
                            return 'Insira um e-mail válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // CPF & CRO Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildLabel('CPF'),
                                _buildTextField(
                                  controller: _cpfController,
                                  hint: '000.000.000-00',
                                  icon: Icons.badge_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'CPF obrigatório';
                                    }
                                    // Remove special characters to check length
                                    final cleanCpf = value.replaceAll(
                                      RegExp(r'[^0-9]'),
                                      '',
                                    );
                                    if (cleanCpf.length != 11) {
                                      return 'CPF inválido';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildLabel('CRO'),
                                _buildTextField(
                                  controller: _croController,
                                  hint: '12345-UF',
                                  icon: Icons.verified_outlined,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'CRO obrigatório';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      _buildLabel('Telefone / Celular'),
                      _buildTextField(
                        controller: _phoneController,
                        hint: '(00) 00000-0000',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Insira seu telefone';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      _buildLabel('Senha'),
                      _buildTextField(
                        controller: _passwordController,
                        hint: 'Mínimo 6 caracteres',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Crie uma senha';
                          }
                          if (value.length < 6) {
                            return 'Senha deve ter no mínimo 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Register Button
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
                                'Registrar Profissional',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFCBD5E1),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF06B6D4), width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}
