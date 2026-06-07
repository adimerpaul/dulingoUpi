import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../widgets/lumo_button.dart';
import '../../widgets/lumo_logo.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.viewModel});

  final AuthViewModel viewModel;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.panel,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LumoLogo(size: 60, showText: false),
                      const SizedBox(height: 18),
                      const Text(
                        'Bienvenido a Lumo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Inicia sesion para continuar aprendiendo ingles',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 26),
                      _Field(controller: email, label: 'Correo electronico'),
                      const SizedBox(height: 14),
                      _Field(
                        controller: password,
                        label: 'Contrasena',
                        obscure: true,
                      ),
                      if (widget.viewModel.error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          widget.viewModel.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.red),
                        ),
                      ],
                      const SizedBox(height: 18),
                      LumoButton(
                        label: widget.viewModel.loading
                            ? 'Cargando...'
                            : 'Iniciar sesion',
                        onPressed: widget.viewModel.loading
                            ? null
                            : () => widget.viewModel.login(
                                email.text,
                                password.text,
                              ),
                      ),
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  RegisterView(viewModel: widget.viewModel),
                            ),
                          );
                        },
                        child: const Text(
                          'No tienes cuenta? Registrate gratis',
                        ),
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
      style: const TextStyle(fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.panel2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 2),
        ),
      ),
    );
  }
}
