import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0E1116);
  static const bg2 = Color(0xFF0A0D12);
  static const panel = Color(0xFF161D26);
  static const panel2 = Color(0xFF1B232E);
  static const panel3 = Color(0xFF212C38);
  static const border = Color(0xFF27313D);
  static const borderStrong = Color(0xFF37434F);
  static const text = Color(0xFFEEF2F5);
  static const muted = Color(0xFF8A97A5);
  static const muted2 = Color(0xFF5F6C79);
  static const primary = Color(0xFFFF7A45);
  static const primaryDark = Color(0xFFCF5A2C);
  static const amber = Color(0xFFFFC53D);
  static const amberDark = Color(0xFFD99C1D);
  static const green = Color(0xFF5FCF2F);
  static const red = Color(0xFFFF5B5B);
  static const gem = Color(0xFF38C6F4);
  static const heart = Color(0xFFFF5D6C);

  static Color soft(Color color, [double opacity = .14]) {
    return color.withValues(alpha: opacity);
  }
}
