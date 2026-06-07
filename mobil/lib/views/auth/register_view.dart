import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../widgets/lumo_button.dart';
import '../../widgets/lumo_logo.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key, required this.viewModel});

  final AuthViewModel viewModel;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final nombre = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final password2 = TextEditingController();
  String? localError;

  @override
  void dispose() {
    nombre.dispose();
    email.dispose();
    password.dispose();
    password2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(backgroundColor: AppColors.bg),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.panel,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: Column(
                    children: [
                      const LumoLogo(size: 60, showText: false),
                      const SizedBox(height: 18),
                      const Text(
                        'Crea tu cuenta',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _Field(controller: nombre, label: 'Tu nombre'),
                      const SizedBox(height: 14),
                      _Field(controller: email, label: 'Correo electronico'),
                      const SizedBox(height: 14),
                      _Field(
                        controller: password,
                        label: 'Contrasena',
                        obscure: true,
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        controller: password2,
                        label: 'Confirmar contrasena',
                        obscure: true,
                      ),
                      if (localError != null ||
                          widget.viewModel.error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          localError ?? widget.viewModel.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.red),
                        ),
                      ],
                      const SizedBox(height: 18),
                      LumoButton(
                        label: 'Crear cuenta gratis',
                        onPressed: widget.viewModel.loading ? null : _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (password.text != password2.text) {
      setState(() => localError = 'Las contrasenas no coinciden');
      return;
    }
    setState(() => localError = null);
    final ok = await widget.viewModel.register(
      nombre.text,
      email.text,
      password.text,
    );
    if (ok && mounted) Navigator.of(context).pop();
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.obscure = false,
  });

  final TextEditingController controller;
  final String label;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.panel2,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
