import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class TopBarStats extends StatelessWidget {
  final ProgressService progressService;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenPaywall;
  final VoidCallback onOpenLeague;
  final VoidCallback onOpenDevSheet;

  const TopBarStats({
    super.key,
    required this.progressService,
    required this.onOpenProfile,
    required this.onOpenPaywall,
    required this.onOpenLeague,
    required this.onOpenDevSheet,
  });

  @override
  Widget build(BuildContext context) {
    final progress = progressService.progress;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 0. Botão Voltar ao Perfil do Usuário
          GestureDetector(
            onTap: onOpenProfile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: progress.isVip
                      ? AppTheme.prestigeGold.withValues(alpha: 0.6)
                      : AppTheme.focusCyan.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    progress.isVip ? Icons.workspace_premium : Icons.person_rounded,
                    size: 16,
                    color: progress.isVip ? AppTheme.prestigeGold : AppTheme.focusCyan,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Perfil',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 1. Contador de Ofensiva (Streak)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.habitAmber.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, size: 16, color: AppTheme.habitAmber),
                const SizedBox(width: 3),
                Text(
                  '${progress.streak}',
                  style: GoogleFonts.orbitron(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.habitAmber,
                  ),
                ),
              ],
            ),
          ),

          // 2. Desafios Diários Restantes
          GestureDetector(
            onTap: onOpenPaywall,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: progress.isDevUnlimited
                      ? AppTheme.calmIndigo
                      : progress.isVip
                          ? AppTheme.prestigeGold
                          : AppTheme.focusCyan.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    color: progress.isDevUnlimited
                        ? AppTheme.calmIndigo
                        : progress.isVip
                            ? AppTheme.prestigeGold
                            : AppTheme.focusCyan,
                    size: 16,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    progress.isDevUnlimited
                        ? '∞ INF'
                        : '${progress.dailyChallengesLeft}/${progress.maxChallenges}',
                    style: GoogleFonts.orbitron(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: progress.isDevUnlimited
                          ? AppTheme.calmIndigo
                          : progress.isVip
                              ? AppTheme.prestigeGold
                              : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Botão da Liga Semanal & XP
          GestureDetector(
            onTap: onOpenLeague,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.prestigeGold.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.military_tech_rounded, color: AppTheme.prestigeGold, size: 16),
                  const SizedBox(width: 3),
                  Text(
                    '${progress.weeklyXp}',
                    style: GoogleFonts.orbitron(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppTheme.prestigeGold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Botão de Ferramentas / Dev
          IconButton(
            tooltip: 'Ferramentas de Teste',
            icon: const Icon(Icons.tune_rounded, color: AppTheme.textMuted, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onOpenDevSheet,
          ),
        ],
      ),
    );
  }
}
