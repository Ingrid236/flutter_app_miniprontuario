import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
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
  final _croNumberController = TextEditingController();
  final _phoneController = TextEditingController();

  final _cpfFormatter = AppFormatters.cpfFormatter;
  final _phoneFormatter = AppFormatters.phoneFormatter;

  final List<String> _brazilianStates = const [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
    'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
    'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
  ];
  String _selectedCroState = 'SP';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cpfController.dispose();
    _croNumberController.dispose();
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
          cro: 'CRO-$_selectedCroState ${_croNumberController.text.trim()}',
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
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
              Text(
                'Criar Conta',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cadastre seus dados profissionais para começar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // Registration Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
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
                            return 'Nome incompleto. O nome é obrigatório para identificá-lo no prontuário. Por favor, insira seu nome completo.';
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
                            return 'E-mail ausente. O e-mail é necessário para realizar o login e receber alertas. Por favor, preencha o campo de e-mail.';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                            return 'E-mail inválido. O formato digitado não é um e-mail válido. Por favor, insira um e-mail no formato correto (exemplo@odontologia.com).';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // CPF Field
                      _buildLabel('CPF'),
                      _buildTextField(
                        controller: _cpfController,
                        hint: '000.000.000-00',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_cpfFormatter],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'CPF ausente. O CPF é obrigatório para identificação profissional única. Por favor, insira seu CPF completo.';
                          }
                          final cleanCpf = value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (cleanCpf.length != 11) {
                            return 'CPF incompleto. O CPF deve conter exatamente 11 dígitos numéricos. Por favor, preencha o CPF por completo (000.000.000-00).';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // CRO Field
                      _buildLabel('CRO (Conselho Regional de Odontologia)'),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 90,
                            child: DropdownButtonFormField<String>(
                              value: _selectedCroState,
                              dropdownColor: Theme.of(context).colorScheme.surface,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Theme.of(context).scaffoldBackgroundColor,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: _brazilianStates.map((uf) {
                                return DropdownMenuItem(
                                  value: uf,
                                  child: Text(uf),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedCroState = val;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _croNumberController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                              decoration: InputDecoration(
                                hintText: 'Número de Registro',
                                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                filled: true,
                                fillColor: Theme.of(context).scaffoldBackgroundColor,
                                prefixIcon: Icon(Icons.verified_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'CRO ausente. O número do registro é obrigatório. Por favor, insira seu CRO.';
                                }
                                if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                                  return 'Formato incorreto. O CRO deve conter apenas números. Por favor, insira somente dígitos.';
                                }
                                return null;
                              },
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
                        inputFormatters: [_phoneFormatter],
                        onChanged: (value) {
                          final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (clean.length <= 10) {
                            _phoneFormatter.updateMask(mask: '(##) ####-####');
                          } else {
                            _phoneFormatter.updateMask(mask: '(##) #####-####');
                          }
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Telefone ausente. O telefone é necessário para contato com a clínica. Por favor, insira seu número de telefone com DDD.';
                          }
                          final cleanPhone = value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (cleanPhone.length < 10) {
                            return 'Telefone incompleto. O número inserido é curto demais. Por favor, insira o DDD + 8 ou 9 dígitos.';
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
                            return 'Senha ausente. Uma senha é obrigatória para proteger seu acesso. Por favor, crie uma senha.';
                          }
                          if (value.length < 6) {
                            return 'Senha fraca. A senha deve possuir pelo menos 6 caracteres. Por favor, digite uma senha mais longa.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Register Button
                      ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.onPrimary,
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
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
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
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}
