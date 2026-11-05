import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/league_player.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class LeagueScreen extends StatelessWidget {
  final ProgressService progressService;

  const LeagueScreen({super.key, required this.progressService});

  @override
  Widget build(BuildContext context) {
    final userProgress = progressService.progress;
    final players = LeagueService.generateRankedList(userProgress.weeklyXp);
    final userRank = LeagueService.getUserRank(userProgress.weeklyXp);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: AppBar(
              title: Column(
                children: [
                  Text(
                    userProgress.leagueTier.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1.5,
                      color: AppTheme.gold,
                    ),
                  ),
                  Text(
                    'Reset semanal em 3d 14h',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              _buildUserPositionBanner(userRank, userProgress.weeklyXp),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    final rank = index + 1;

                    Widget? zoneDivider;
                    if (index == LeagueService.promotionThreshold) {
                      zoneDivider = _buildZoneMarker(
                        '⬆️ TOP 7 SOBEM PARA A PRÓXIMA LIGA',
                        AppTheme.neonGreen,
                      );
                    } else if (index == LeagueService.relegationThreshold) {
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
        ),
      ),
    );
  }

  Widget _buildUserPositionBanner(int userRank, int weeklyXp) {
    final isPromo = LeagueService.isPromotion(userRank);
    final isReleg = LeagueService.isRelegation(userRank);
    final statusColor = isPromo
        ? AppTheme.neonGreen
        : isReleg
            ? AppTheme.neonPink
            : AppTheme.neonCyan;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        border: Border(bottom: BorderSide(color: statusColor.withValues(alpha: 0.4))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.leaderboard, color: statusColor, size: 22),
              const SizedBox(width: 8),
              Text(
                'Sua Posição: #$userRank de 30',
                style: GoogleFonts.orbitron(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Text(
            '$weeklyXp XP',
            style: GoogleFonts.orbitron(
              fontWeight: FontWeight.bold,
              color: AppTheme.gold,
              fontSize: 14,
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
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.orbitron(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard(LeaguePlayer player, int rank) {
    Widget rankWidget;
    if (rank == 1) {
      rankWidget = const Icon(Icons.emoji_events, color: AppTheme.gold, size: 24);
    } else if (rank == 2) {
      rankWidget = const Icon(Icons.emoji_events, color: Colors.grey, size: 22);
    } else if (rank == 3) {
      rankWidget = const Icon(Icons.emoji_events, color: Colors.brown, size: 20);
    } else {
      rankWidget = Text(
        '#$rank',
        style: GoogleFonts.orbitron(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.white70,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: player.isCurrentUser
            ? AppTheme.neonCyan.withValues(alpha: 0.15)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: player.isCurrentUser
              ? AppTheme.neonCyan
              : Colors.white.withValues(alpha: 0.05),
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
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppTheme.gold,
          ),
        ),
      ),
    );
  }
}
