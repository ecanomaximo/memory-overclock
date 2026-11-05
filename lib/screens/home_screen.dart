import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/phase_node.dart';
import '../services/cadence_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/activity_cadence_bar.dart';
import '../widgets/phase_node_widget.dart';
import '../widgets/top_bar_stats.dart';
import 'league_screen.dart';
import 'paywall_screen.dart';
import 'wave_activity_screen.dart';

class HomeScreen extends StatelessWidget {
  final ProgressService progressService;
  final CadenceService? cadenceService;
  final VoidCallback? onOpenProfile;

  const HomeScreen({
    super.key,
    required this.progressService,
    this.cadenceService,
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

        final effectiveCadence = cadenceService ??
            CadenceService(isVip: progressService.progress.isVip);

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
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
                    ActivityCadenceBar(
                      cadenceService: effectiveCadence,
                      onCadenceExhaustedTap: () => _openPaywall(context),
                    ),
                    Expanded(
                      child: _buildDuolingoTrack(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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

    final effectiveCadence = cadenceService ??
        CadenceService(isVip: progressService.progress.isVip);

    if (!effectiveCadence.canStartActivity()) {
      _showCadenceExhaustedDialog(context, effectiveCadence);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaveActivityScreen(
          phaseLevel: node.id,
          progressService: progressService,
          cadenceService: effectiveCadence,
        ),
      ),
    );
  }

  void _showCadenceExhaustedDialog(BuildContext context, CadenceService cadence) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.timer_off_outlined, color: AppTheme.habitAmber),
            const SizedBox(width: 8),
            Text(
              'Ciclo Concluído (5/5)',
              style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Você completou as 5 atividades deste ciclo. Seu cérebro precisa de um intervalo para consolidação de memória.',
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: AppTheme.focusCyan),
                  const SizedBox(width: 8),
                  Text(
                    'Próxima recarga em: ${cadence.formatTimeRemaining()}',
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.focusCyan,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.prestigeGold,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _openPaywall(context);
            },
            child: const Text('Desbloquear VIP'),
          ),
        ],
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
