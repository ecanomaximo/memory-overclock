import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  final ProgressService progressService;

  const LoginScreen({super.key, required this.progressService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo e Ícone Futurista
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.neonCyan, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonCyan.withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.psychology, color: AppTheme.neonCyan, size: 44),
                  ),
                ),
                const SizedBox(height: 20),

                // Título
                Text(
                  'OVERCLOCK',
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Treine sua memória e foco todos os dias.\nVença o Brain Rot.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 28),

                // Destaques Rápidos
                _buildFeatureItem(Icons.bolt, '3 Desafios Diários de alta performance', AppTheme.neonCyan),
                const SizedBox(height: 10),
                _buildFeatureItem(Icons.military_tech, 'Ligas Semanais e Ranking com 30 rivais', AppTheme.gold),
                const SizedBox(height: 10),
                _buildFeatureItem(Icons.sync, 'Progresso offline com sincronização automática', AppTheme.neonGreen),

                const SizedBox(height: 32),

                // Botão 1: Entrar com o Google
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.redAccent),
                    label: Text(
                      'Continuar com o Google',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => progressService.loginWithGoogle(),
                  ),
                ),
                const SizedBox(height: 12),

                // Botão 2: Entrar com Apple / iCloud
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surfaceElevated,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.apple, size: 26),
                    label: Text(
                      'Continuar com Apple / iCloud',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => progressService.loginWithApple(),
                  ),
                ),
                const SizedBox(height: 14),

                // Botão Convidado (modo teste rápido)
                TextButton(
                  onPressed: () => progressService.loginAsGuest(),
                  child: Text(
                    'Entrar como Convidado (Modo Teste)',
                    style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
