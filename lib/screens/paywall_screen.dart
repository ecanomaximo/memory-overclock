import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class PaywallScreen extends StatelessWidget {
  final ProgressService progressService;

  const PaywallScreen({super.key, required this.progressService});

  @override
  Widget build(BuildContext context) {
    final isAlreadyVip = progressService.progress.isVip;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.workspace_premium, color: AppTheme.gold, size: 54),
          const SizedBox(height: 12),
          const Text(
            'OVERCLOCK VIP',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: AppTheme.gold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Atingiu o limite diário de 3 desafios gratuitos!\nDesbloqueie seu cérebro para subir nas ligas.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          _buildBenefitRow(
            icon: Icons.bolt,
            color: AppTheme.neonCyan,
            title: '10 Desafios Diários',
            subtitle: 'Treine muito mais que os adversários comuns',
          ),
          const SizedBox(height: 14),
          _buildBenefitRow(
            icon: Icons.military_tech,
            color: AppTheme.neonPurple,
            title: 'XP 1.5x Acelerado',
            subtitle: 'Suba mais rápido para a Liga de Diamante',
          ),
          const SizedBox(height: 14),
          _buildBenefitRow(
            icon: Icons.shield,
            color: AppTheme.neonGreen,
            title: 'Selo Dourado VIP',
            subtitle: 'Destaque-se no ranking da semana',
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isAlreadyVip ? Colors.redAccent : AppTheme.gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
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
                            ? 'Plano VIP desativado (Modo Grátis: 3/dia).'
                            : '🎉 Parabéns! Plano VIP ativado com sucesso!',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
              },
              child: Text(
                isAlreadyVip ? 'CANCELAR PLANO VIP' : 'ASSINAR POR R\$ 9,90 / MÊS',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Cancele quando quiser na Google Play Store.',
            style: TextStyle(fontSize: 12, color: Colors.white38),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.white60),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
