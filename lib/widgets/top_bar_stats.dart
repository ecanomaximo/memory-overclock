import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class TopBarStats extends StatelessWidget {
  final ProgressService progressService;
  final VoidCallback onOpenPaywall;
  final VoidCallback onOpenLeague;
  final VoidCallback onOpenDevSheet;

  const TopBarStats({
    super.key,
    required this.progressService,
    required this.onOpenPaywall,
    required this.onOpenLeague,
    required this.onOpenDevSheet,
  });

  @override
  Widget build(BuildContext context) {
    final progress = progressService.progress;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Contador de Ofensiva (Streak)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.streakOrange.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '${progress.streak}',
                  style: GoogleFonts.orbitron(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.streakOrange,
                  ),
                ),
              ],
            ),
          ),

          // 2. Desafios Diários Restantes
          GestureDetector(
            onTap: onOpenPaywall,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: progress.isDevUnlimited
                      ? AppTheme.neonPurple
                      : progress.isVip
                          ? AppTheme.gold
                          : AppTheme.neonCyan.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bolt,
                    color: progress.isDevUnlimited
                        ? AppTheme.neonPurple
                        : progress.isVip
                            ? AppTheme.gold
                            : AppTheme.neonCyan,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    progress.isDevUnlimited
                        ? '∞ INF'
                        : '${progress.dailyChallengesLeft}/${progress.maxChallenges}',
                    style: GoogleFonts.orbitron(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: progress.isDevUnlimited
                          ? AppTheme.neonPurple
                          : progress.isVip
                              ? AppTheme.gold
                              : Colors.white,
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
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.military_tech, color: AppTheme.gold, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${progress.weeklyXp} XP',
                    style: GoogleFonts.orbitron(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppTheme.gold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Botão de Ferramentas / Dev
          IconButton(
            tooltip: 'Ferramentas de Teste',
            icon: const Icon(Icons.tune, color: Colors.white70, size: 22),
            onPressed: onOpenDevSheet,
          ),
        ],
      ),
    );
  }
}
