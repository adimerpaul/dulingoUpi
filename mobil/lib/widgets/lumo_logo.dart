import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class LumoLogo extends StatelessWidget {
  const LumoLogo({super.key, this.size = 46, this.showText = true});

  final double size;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFFF9A3D),
            borderRadius: BorderRadius.circular(size * .28),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: size * .24,
                top: size * .38,
                child: _Eye(size: size * .33),
              ),
              Positioned(
                right: size * .24,
                top: size * .38,
                child: _Eye(size: size * .33),
              ),
              Positioned(
                bottom: size * .18,
                child: Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.amber,
                  size: size * .45,
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          const Text(
            'Lumo',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ],
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: size * .42,
          height: size * .42,
          decoration: const BoxDecoration(
            color: Color(0xFF33271A),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
