import 'package:flutter/material.dart';

class AppTheme {
  // Cores Modernas: Fundo escuro com toques de Neon e Cores Vibrantes
  static const Color background = Color(0xFF0F172A); // Slate escuro
  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceElevated = Color(0xFF334155);

  // Acentos
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonPurple = Color(0xFFA855F7);
  static const Color neonPink = Color(0xFFFF007F);
  static const Color neonGreen = Color(0xFF10B981);
  static const Color streakOrange = Color(0xFFFF7A00);
  static const Color gold = Color(0xFFFFD700);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonPurple,
        surface: surface,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
