import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class LumoButton extends StatelessWidget {
  const LumoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.borderColor = AppColors.primaryDark,
    this.outline = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color borderColor;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? .55 : 1,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
          decoration: BoxDecoration(
            color: outline ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(
                color: outline ? AppColors.borderStrong : borderColor,
                width: 2,
              ),
              top: BorderSide(
                color: outline ? AppColors.borderStrong : borderColor,
                width: 2,
              ),
              right: BorderSide(
                color: outline ? AppColors.borderStrong : borderColor,
                width: 2,
              ),
              bottom: BorderSide(
                color: outline ? AppColors.borderStrong : borderColor,
                width: 4,
              ),
            ),
          ),
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: outline ? AppColors.muted : Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
        ),
      ),
    );
  }
}
