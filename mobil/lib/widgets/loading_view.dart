import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.text = 'Cargando...'});

  final String text;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}
