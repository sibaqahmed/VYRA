import 'package:flutter/material.dart';

class AppColors {
  // 🌌 Brand
  static const Color primary = Color(0xFF7C7CFF); // Soft Neon Violet
  static const Color accent = Color(0xFF00E5FF);  // Electric Cyan

  // 🌑 Background Layers (VERY IMPORTANT)
  static const Color background = Color(0xFF0B0E1A); // Deep night
  static const Color surface = Color(0xFF14172E);    // Cards / sheets
  static const Color surfaceLight = Color(0xFF1E2248); // Elevated cards

  // 📝 Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9AA4C7);
  static const Color textMuted = Color(0xFF6B7399);

  // 🚦 States
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFFF5252);

  // 🌈 Gradients (FOR HERO SECTIONS / BUTTONS)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF7C7CFF),
      Color(0xFF5F5CFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [
      Color(0xFF00E5FF),
      Color(0xFF00B0FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
