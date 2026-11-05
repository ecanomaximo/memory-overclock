import 'package:flutter/material.dart';
import '../models/league_model.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class LeagueScreen extends StatelessWidget {
  final ProgressService progressService;

  const LeagueScreen({super.key, required this.progressService});

  @override
  Widget build(BuildContext context) {
    final userProgress = progressService.progress;
    final players = LeagueManager.generateLeague(userProgress.weeklyXp);
    final userIndex = players.indexWhere((p) => p.isCurrentUser);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              userProgress.leagueTier.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 1.2,
                color: AppTheme.gold,
              ),
            ),
            const Text(
              'Reset semanal em 3d 14h',
              style: TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Banner de Destaque da Posição do Usuário
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppTheme.surfaceElevated,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.leaderboard, color: AppTheme.neonCyan),
                    const SizedBox(width: 8),
                    Text(
                      'Sua Posição: #${userIndex + 1} de 30',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${userProgress.weeklyXp} XP',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.gold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                final rank = index + 1;

                Widget? zoneDivider;
                if (index == 7) {
                  // Linha de corte de promoção
                  zoneDivider = _buildZoneMarker(
                    '⬆️ TOP 7 SOBEM PARA A PRÓXIMA LIGA',
                    AppTheme.neonGreen,
                  );
                } else if (index == 25) {
                  // Linha de corte de rebaixamento
                  zoneDivider = _buildZoneMarker(
                    '⬇️ ÚLTIMOS 5 CAEM DE DIVISÃO',
                    AppTheme.neonPink,
                  );
                }

                return Column(
                  children: [
                    if (zoneDivider != null) zoneDivider,
                    _buildPlayerCard(player, rank),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneMarker(String label, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard(LeaguePlayer player, int rank) {
    Color rankColor = Colors.white70;
    Widget rankWidget = Text(
      '#$rank',
      style: TextStyle(fontWeight: FontWeight.bold, color: rankColor),
    );

    if (rank == 1) {
      rankWidget = const Icon(Icons.emoji_events, color: AppTheme.gold, size: 24);
    } else if (rank == 2) {
      rankWidget = const Icon(Icons.emoji_events, color: Colors.grey, size: 22);
    } else if (rank == 3) {
      rankWidget = const Icon(Icons.emoji_events, color: Colors.brown, size: 20);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: player.isCurrentUser
            ? AppTheme.neonCyan.withOpacity(0.15)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: player.isCurrentUser
              ? AppTheme.neonCyan
              : Colors.white.withOpacity(0.05),
          width: player.isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        leading: SizedBox(
          width: 36,
          child: Center(child: rankWidget),
        ),
        title: Row(
          children: [
            Text(player.avatarEmoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                player.name,
                style: TextStyle(
                  fontWeight: player.isCurrentUser ? FontWeight.w900 : FontWeight.w600,
                  color: player.isCurrentUser ? AppTheme.neonCyan : Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Text(
          '${player.xp} XP',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppTheme.gold,
          ),
        ),
      ),
    );
  }
}
