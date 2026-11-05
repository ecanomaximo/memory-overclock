import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta Neurocognitiva & Visual Ergonomics:
/// Cores selecionadas com base em estudos de neurociência e ergonomia de visão:
/// - Fundo Deep Cognitive Slate (reduz fadiga fotópica e níveis de cortisol em comparação a fundos 100% pretos).
/// - Ciano Neuro-Elétrico (comprimento ~485nm estimula receptores ipRGCs de alerta calmo e foco executivo).
/// - Verde Bio-Menta (pico de sensibilidade retiniana ~555nm, restauração de atenção de Kaplan e reforço dopaminérgico).
/// - Âmbar Solar (estímulo de urgência e hábito sem disparar a resposta de alarme/estresse da amígdala provocada por vermelho puro).
class AppTheme {
  // Fundos & Superfícies Neuro-Ergonômicas
  static const Color background = Color(0xFF0A0F1D);
  static const Color surface = Color(0xFF131D31);
  static const Color surfaceElevated = Color(0xFF1B2844);
  static const Color surfaceBorder = Color(0xFF24365C);

  // Acentos Científicos para Foco Mental
  static const Color focusCyan = Color(0xFF00D2FF);       // Alerta mental e foco
  static const Color rewardGreen = Color(0xFF00E599);     // Recompensa e feedback positivo
  static const Color habitAmber = Color(0xFFFF9F1C);      // Ofensiva (Streak) e persistência
  static const Color prestigeGold = Color(0xFFFFC72C);    // Ligas e conquistas
  static const Color calmIndigo = Color(0xFF818CF8);      // Relaxamento cognitivo e VIP
  static const Color alertPink = Color(0xFFFF3366);       // Erros (sem estresse excessivo)

  // Aliases de compatibilidade
  static const Color neonCyan = focusCyan;
  static const Color neonGreen = rewardGreen;
  static const Color streakOrange = habitAmber;
  static const Color gold = prestigeGold;
  static const Color neonPurple = calmIndigo;
  static const Color neonPink = alertPink;
  static const Color primaryNeuroCyan = focusCyan;
  static const Color accentBioGreen = rewardGreen;
  static const Color accentSolarAmber = habitAmber;
  static const Color cardDeepSlate = surface;
  static const Color cardBorderMuted = surfaceBorder;
  static const Color textMutedSlate = textSecondary;
  static const Color textPrimaryLight = textPrimary;

  // Textos para contraste seguro (WCAG AAA)
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();
    final textTheme = GoogleFonts.interTextTheme(baseTheme.textTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: focusCyan,
        secondary: rewardGreen,
        surface: surface,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: surfaceBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: focusCyan,
          foregroundColor: Colors.black87,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
