import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final ProgressService progressService;

  const LoginScreen({super.key, required this.progressService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String _activeProvider = '';

  Future<void> _handleGoogleLogin() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _activeProvider = 'Google';
    });

    final result = await widget.progressService.loginWithGoogle();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _activeProvider = '';
      });

      if (!result.success && result.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage!),
            backgroundColor: AppTheme.alertPink,
          ),
        );
      }
    }
  }



  Future<void> _handleAppleLogin() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _activeProvider = 'Apple';
    });

    final result = await widget.progressService.loginWithApple();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _activeProvider = '';
      });

      if (!result.success && result.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage!),
            backgroundColor: AppTheme.alertPink,
          ),
        );
      }
    }
  }

  Future<void> _handleGithubLogin() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _activeProvider = 'GitHub';
    });

    final result = await widget.progressService.loginWithGithub();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _activeProvider = '';
      });

      if (!result.success && result.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage!),
            backgroundColor: AppTheme.alertPink,
          ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                // Logo Futurista
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.focusCyan, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.focusCyan.withValues(alpha: 0.35),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.psychology_rounded, color: AppTheme.focusCyan, size: 44),
                  ),
                ),
                const SizedBox(height: 20),

                // Título
                Text(
                  'MEMORY OVERCLOCK',
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Treine sua memória e foco todos os dias.\nVença o Brain Rot com neurociência.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 28),

                // Destaques Rápidos
                _buildFeatureItem(Icons.bolt_rounded, '5 Atividades a cada 5 horas em ondas de 3 jogos', AppTheme.focusCyan),
                const SizedBox(height: 10),
                _buildFeatureItem(Icons.military_tech_rounded, 'Ligas Semanais e Ranking com 30 rivais', AppTheme.prestigeGold),
                const SizedBox(height: 10),
                _buildFeatureItem(Icons.cloud_done_rounded, 'Autenticação segura e sincronização em nuvem', AppTheme.rewardGreen),

                const SizedBox(height: 32),

                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.focusCyan),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Conectando $_activeProvider...',
                          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.focusCyan),
                        ),
                      ],
                    ),
                  ),

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
                    onPressed: _isLoading ? null : _handleGoogleLogin,
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
                      side: const BorderSide(color: AppTheme.surfaceBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.apple, size: 26),
                    label: Text(
                      'Continuar com Apple / iCloud',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _isLoading ? null : _handleAppleLogin,
                  ),
                ),
                const SizedBox(height: 12),

                // Botão 3: Entrar com GitHub
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24292E),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppTheme.surfaceBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.code_rounded, size: 24, color: AppTheme.focusCyan),
                    label: Text(
                      'Continuar com GitHub',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _isLoading ? null : _handleGithubLogin,
                  ),
                ),
                const SizedBox(height: 14),

                // Botão Convidado (modo teste rápido)
                TextButton(
                  onPressed: _isLoading ? null : () => widget.progressService.loginAsGuest(),
                  child: Text(
                    'Entrar como Convidado (Modo Offline / Teste)',
                    style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ),
              ],
            ),
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
        border: Border.all(color: AppTheme.surfaceBorder),
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
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
