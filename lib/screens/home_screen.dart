import 'dart:math';
import 'package:flutter/material.dart';
import '../games/color_clash_game.dart';
import '../games/flash_matrix_game.dart';
import '../games/reading_recall_game.dart';
import '../models/game_type.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import 'league_screen.dart';
import 'paywall_screen.dart';

class HomeScreen extends StatelessWidget {
  final ProgressService progressService;

  const HomeScreen({super.key, required this.progressService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: progressService,
      builder: (context, _) {
        if (!progressService.isInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.neonCyan),
            ),
          );
        }

        return Scaffold(
          appBar: _buildTopBar(context),
          body: Column(
            children: [
              _buildDailyLimitBanner(context),
              Expanded(
                child: _buildDuolingoTrack(context),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildTopBar(BuildContext context) {
    final progress = progressService.progress;

    return AppBar(
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Contador de Ofensiva (Streak)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: AppTheme.streakOrange,
                  ),
                ),
              ],
            ),
          ),

          // 2. Desafios Diários Restantes (3/3 ou VIP ou Infinito)
          GestureDetector(
            onTap: () => _openPaywall(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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

          // 3. Botão da Liga Semanal
          IconButton(
            tooltip: 'Ligas e Ranking',
            icon: const Icon(Icons.military_tech, color: AppTheme.gold, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LeagueScreen(progressService: progressService),
                ),
              );
            },
          ),

          // 4. Painel de Testes / Modo Dev
          IconButton(
            tooltip: 'Modo Teste / Dev Tools',
            icon: const Icon(Icons.handyman_rounded, color: AppTheme.neonPink, size: 24),
            onPressed: () => _openDevSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyLimitBanner(BuildContext context) {
    final progress = progressService.progress;

    if (!progress.isDevUnlimited && progress.dailyChallengesLeft == 0 && !progress.isVip) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.neonPink.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.neonPink.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_clock, color: AppTheme.neonPink),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Limite diário gratuito atingido (3/3)!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              onPressed: () => _openPaywall(context),
              child: const Text('SER VIP', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDuolingoTrack(BuildContext context) {
    const totalLevels = 20;
    final userCurrentLevel = progressService.progress.currentLevel;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 24),
      itemCount: totalLevels,
      itemBuilder: (context, index) {
        final level = index + 1;
        final config = LevelConfig.getConfig(level);
        final isUnlocked = level <= userCurrentLevel;
        final isCompleted = level < userCurrentLevel;
        final isCurrent = level == userCurrentLevel;

        final double horizontalOffset = sin(index * 0.9) * 85;

        return Center(
          child: Transform.translate(
            offset: Offset(horizontalOffset, 0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                children: [
                  _buildTrackNode(
                    context: context,
                    config: config,
                    isUnlocked: isUnlocked,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      config.title,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isCurrent
                            ? AppTheme.neonCyan
                            : isCompleted
                                ? AppTheme.neonGreen
                                : Colors.white54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrackNode({
    required BuildContext context,
    required LevelConfig config,
    required bool isUnlocked,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    final isBoss = config.icon == Icons.military_tech;
    Color nodeColor = AppTheme.surfaceElevated;
    Widget innerIcon = Icon(Icons.lock, color: Colors.white24, size: isBoss ? 28 : 24);

    if (isCompleted) {
      nodeColor = AppTheme.neonGreen;
      innerIcon = const Icon(Icons.check, color: Colors.black, size: 30);
    } else if (isCurrent) {
      if (isBoss) {
        nodeColor = AppTheme.neonPink;
      } else {
        switch (config.type) {
          case GameType.matrix:
            nodeColor = AppTheme.neonCyan;
            break;
          case GameType.colors:
            nodeColor = AppTheme.neonPurple;
            break;
          case GameType.reading:
            nodeColor = AppTheme.gold;
            break;
        }
      }
      innerIcon = Icon(config.icon, color: Colors.black, size: 30);
    } else if (isUnlocked) {
      innerIcon = Icon(config.icon, color: Colors.white70, size: 26);
    }

    final double size = isBoss ? 76.0 : 66.0;

    return GestureDetector(
      onTap: () {
        if (!isUnlocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conclua as fases anteriores para desbloquear! (Ou use o botão 🛠️ de Teste)'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }

        if (!progressService.canPlay()) {
          _openPaywall(context);
          return;
        }

        Widget targetGame;
        switch (config.type) {
          case GameType.matrix:
            targetGame = FlashMatrixGame(
              level: config.level,
              progressService: progressService,
            );
            break;
          case GameType.colors:
            targetGame = ColorClashGame(
              level: config.level,
              progressService: progressService,
            );
            break;
          case GameType.reading:
            targetGame = ReadingRecallGame(
              level: config.level,
              progressService: progressService,
            );
            break;
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetGame),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isCurrent)
            Container(
              width: size + 14,
              height: size + 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: nodeColor.withValues(alpha: 0.6),
                    blurRadius: 18,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: nodeColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrent ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  offset: const Offset(0, 5),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Center(child: innerIcon),
          ),
          if (isBoss)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.gold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, size: 14, color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }

  void _openPaywall(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaywallScreen(progressService: progressService),
    );
  }

  void _openDevSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final progress = progressService.progress;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.handyman_rounded, color: AppTheme.neonPink),
                  SizedBox(width: 8),
                  Text(
                    'MODO DESENVOLVEDOR / TESTES',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.neonPink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.all_inclusive, color: AppTheme.neonPurple),
                title: const Text('Desafios Infinitos (Sem Limite)'),
                subtitle: Text(progress.isDevUnlimited ? 'Ativado (Jogadas Ilimitadas)' : 'Desativado'),
                trailing: Switch(
                  value: progress.isDevUnlimited,
                  onChanged: (val) {
                    progressService.toggleDevUnlimited();
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.lock_open, color: AppTheme.neonCyan),
                title: const Text('Desbloquear Todas as Fases (1 a 20)'),
                subtitle: const Text('Abre todas as fases da trilha para testar direto'),
                onTap: () {
                  progressService.unlockAllLevels();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🔓 Todas as 20 fases foram desbloqueadas!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.battery_charging_full, color: AppTheme.neonGreen),
                title: const Text('Recarregar Desafios Diários Agora'),
                onTap: () {
                  progressService.refillChallenges();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('⚡ Desafios recarregados!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh, color: Colors.redAccent),
                title: const Text('Resetar Progresso do Zero'),
                onTap: () {
                  progressService.resetProgress();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Progresso resetado para a Fase 1.')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
