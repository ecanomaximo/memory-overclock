import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../games/flash_matrix_game.dart';
import '../models/phase_node.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/phase_node_widget.dart';
import '../widgets/top_bar_stats.dart';
import 'league_screen.dart';
import 'paywall_screen.dart';

class HomeScreen extends StatelessWidget {
  final ProgressService progressService;
  final VoidCallback? onOpenProfile;

  const HomeScreen({
    super.key,
    required this.progressService,
    this.onOpenProfile,
  });

  static const int totalLevels = 20;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: progressService,
      builder: (context, _) {
        if (!progressService.isInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.focusCyan),
            ),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                TopBarStats(
                  progressService: progressService,
                  onOpenProfile: () {
                    if (onOpenProfile != null) {
                      onOpenProfile!();
                    }
                  },
                  onOpenPaywall: () => _openPaywall(context),
                  onOpenLeague: () => _openLeague(context),
                  onOpenDevSheet: () => _openDevSheet(context),
                ),
                _buildDailyLimitBanner(context),
                Expanded(
                  child: _buildDuolingoTrack(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyLimitBanner(BuildContext context) {
    final progress = progressService.progress;

    if (!progress.isDevUnlimited && progress.dailyChallengesLeft == 0 && !progress.isVip) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.neonPink.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.neonPink.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_clock, color: AppTheme.neonPink, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Limite diário gratuito atingido (3/3)!',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () => _openPaywall(context),
              child: Text(
                'SER VIP',
                style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildDuolingoTrack(BuildContext context) {
    final userCurrentLevel = progressService.progress.currentLevel;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemCount: totalLevels,
      itemBuilder: (context, index) {
        final level = index + 1;
        final isBoss = level % 5 == 0;
        final PhaseStatus status;

        if (level < userCurrentLevel) {
          status = PhaseStatus.completed;
        } else if (level == userCurrentLevel) {
          status = PhaseStatus.current;
        } else {
          status = PhaseStatus.locked;
        }

        final double horizontalOffset = sin(index * 0.9) * 80;

        final node = PhaseNode(
          id: level,
          title: isBoss ? 'Chefe Cognitivo' : 'Fase $level',
          isBoss: isBoss,
          status: status,
        );

        return Center(
          child: Transform.translate(
            offset: Offset(horizontalOffset, 0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: PhaseNodeWidget(
                node: node,
                onTap: () => _onNodeTapped(context, node),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onNodeTapped(BuildContext context, PhaseNode node) {
    if (node.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fase ${node.id} bloqueada! Vença a anterior primeiro.'),
          backgroundColor: AppTheme.surfaceElevated,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!progressService.canPlay()) {
      _openPaywall(context);
      return;
    }

    // Consome uma tentativa diária e entra na fase
    progressService.consumeChallenge();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashMatrixGame(
          level: node.id,
          progressService: progressService,
        ),
      ),
    );
  }

  void _openPaywall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaywallScreen(progressService: progressService),
      ),
    );
  }

  void _openLeague(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeagueScreen(progressService: progressService),
      ),
    );
  }

  void _openDevSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MODO DEV & TESTES',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neonPink,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.star, color: AppTheme.gold),
                title: const Text('Alternar VIP (10 jogos/dia, 1.5x XP)'),
                trailing: Switch(
                  value: progressService.progress.isVip,
                  onChanged: (val) {
                    progressService.toggleVip(val);
                    Navigator.pop(ctx);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.all_inclusive, color: AppTheme.neonPurple),
                title: const Text('Jogos Infinitos (Dev Unlimited)'),
                trailing: Switch(
                  value: progressService.progress.isDevUnlimited,
                  onChanged: (val) {
                    progressService.toggleDevUnlimited();
                    Navigator.pop(ctx);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.replay, color: AppTheme.neonCyan),
                title: const Text('Recarregar Desafios Diários'),
                onTap: () {
                  progressService.refillChallenges();
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.restart_alt, color: Colors.redAccent),
                title: const Text('Resetar Todo Progresso'),
                onTap: () {
                  progressService.resetProgress();
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
