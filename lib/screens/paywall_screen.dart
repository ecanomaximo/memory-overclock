import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class PaywallScreen extends StatelessWidget {
  final ProgressService progressService;

  const PaywallScreen({super.key, required this.progressService});

  @override
  Widget build(BuildContext context) {
    final isAlreadyVip = progressService.progress.isVip;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: AppBar(
              title: Text(
                'CLUBE OVERCLOCK',
                style: GoogleFonts.orbitron(letterSpacing: 2.0),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
            children: [
              const Icon(Icons.workspace_premium, color: AppTheme.gold, size: 64),
              const SizedBox(height: 14),
              Text(
                'OVERCLOCK VIP',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: AppTheme.gold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Atingiu o limite de 3 desafios gratuitos/dia?\nDesbloqueie treinos expandidos e domine as ligas.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 28),
              _buildBenefitRow(
                icon: Icons.bolt,
                color: AppTheme.neonCyan,
                title: '10 Desafios Diários',
                subtitle: 'Treine mais que o triplo dos adversários comuns',
              ),
              const SizedBox(height: 14),
              _buildBenefitRow(
                icon: Icons.military_tech,
                color: AppTheme.neonPurple,
                title: 'Bônus de 1.5x no XP Semanal',
                subtitle: 'Alcance a zona de promoção para a Liga Diamante',
              ),
              const SizedBox(height: 14),
              _buildBenefitRow(
                icon: Icons.verified_user,
                color: AppTheme.neonGreen,
                title: 'Badge Dourado Exclusivo',
                subtitle: 'Destaque visual no ranking de 30 competidores',
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAlreadyVip ? AppTheme.neonPink : AppTheme.gold,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    await progressService.toggleVip(!isAlreadyVip);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.surfaceElevated,
                          content: Text(
                            isAlreadyVip
                                ? 'Plano VIP desativado (Retornou a 3/dia).'
                                : '🎉 Plano VIP ativado com sucesso!',
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    isAlreadyVip ? 'DESATIVAR VIP (TESTE)' : 'ASSINAR POR R\$ 9,90 / MÊS',
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Ambiente de teste ativo. Alterne a assinatura a qualquer momento.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
}

  Widget _buildBenefitRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
