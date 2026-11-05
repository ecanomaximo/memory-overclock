import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../games/digit_sequence_game.dart';
import '../games/flash_matrix_game.dart';
import '../games/stroop_reflex_game.dart';
import '../models/wave_models.dart';
import '../services/cadence_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class WaveActivityScreen extends StatefulWidget {
  final int phaseLevel;
  final ProgressService progressService;
  final CadenceService cadenceService;

  const WaveActivityScreen({
    super.key,
    required this.phaseLevel,
    required this.progressService,
    required this.cadenceService,
  });

  @override
  State<WaveActivityScreen> createState() => _WaveActivityScreenState();
}

class _WaveActivityScreenState extends State<WaveActivityScreen> {
  late final List<WaveChallenge> _challenges;
  int _currentChallengeIndex = 0;
  int _currentRound = 1;
  int _challengeLives = 3;
  int _attemptCounter = 0;
  bool _isPhaseCompleted = false;

  // Medição em tempo real de acertos, erros e pontos
  int _hits = 0;
  int _misses = 0;
  int _currentSessionScore = 0;
  int _consecutiveHits = 0;
  int _finalAwardedXp = 0;

  @override
  void initState() {
    super.initState();
    _challenges = WaveChallenge.createPhaseSession(level: widget.phaseLevel);
  }

  WaveChallenge get _activeChallenge => _challenges[_currentChallengeIndex];

  void _onRoundSuccess() {
    _hits++;
    _consecutiveHits++;
    final comboBonus = _consecutiveHits > 2 ? 10 : (_consecutiveHits > 1 ? 5 : 0);
    const baseRoundPoints = 20;
    final gainedPoints = baseRoundPoints + comboBonus;
    _currentSessionScore += gainedPoints;

    if (_currentRound < _activeChallenge.totalRounds) {
      setState(() {
        _currentRound++;
      });
    } else {
      _onChallengeBatteryComplete();
    }
  }

  void _onRoundFail() {
    _misses++;
    _consecutiveHits = 0;

    setState(() {
      _challengeLives--;
      _attemptCounter++;
    });

    if (_challengeLives <= 0) {
      _showFailureDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ops! Tentativa incorreta. Você ainda tem $_challengeLives vida(s). Rodada reiniciada!',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: AppTheme.alertPink,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onChallengeBatteryComplete() {
    if (_currentChallengeIndex < _challenges.length - 1) {
      final finishedTitle = _challenges[_currentChallengeIndex].title;
      setState(() {
        _currentChallengeIndex++;
        _currentRound = 1;
        _challengeLives = 3;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚡ Bateria de "$finishedTitle" superada! Iniciando ${_activeChallenge.title}',
            style: GoogleFonts.inter(
              color: const Color(0xFF0A0F1D),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppTheme.rewardGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      _finishPhaseSession();
    }
  }

  void _finishPhaseSession() {
    final isVip = widget.progressService.progress.isVip;
    const phaseClearBonus = 50;
    final totalBaseScore = _currentSessionScore + phaseClearBonus;
    _finalAwardedXp = isVip ? (totalBaseScore * 1.5).round() : totalBaseScore;

    // Consome atividade na cadência de 5h e desafios do progresso
    widget.cadenceService.consumeActivity();
    widget.progressService.consumeChallenge();

    // Sincroniza XP da fase com o progresso do usuário e ranking semanal das ligas
    widget.progressService.recordGameCompleted(
      levelCompleted: widget.phaseLevel,
      earnedXp: _finalAwardedXp,
    );

    setState(() {
      _isPhaseCompleted = true;
    });
  }

  void _showFailureDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Vidas Esgotadas',
          style: GoogleFonts.orbitron(
            color: AppTheme.alertPink,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Você não conseguiu superar ${_activeChallenge.title}. Deseja reiniciar a bateria deste jogo?',
          style: GoogleFonts.inter(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Sair para a Trilha'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.focusCyan,
              foregroundColor: AppTheme.background,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _challengeLives = 3;
                _currentRound = 1;
                _attemptCounter++;
              });
            },
            child: const Text('Reiniciar Bateria'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isPhaseCompleted) {
      return _buildCompletionView();
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: AppBar(
              backgroundColor: AppTheme.background,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'FASE ${widget.phaseLevel} • SESSÃO',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_rounded, color: AppTheme.alertPink, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '$_challengeLives',
                        style: GoogleFonts.orbitron(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.alertPink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  _buildLiveStatsHeader(),
                  const SizedBox(height: 12),
                  _buildGameBatteryProgression(),
                  const SizedBox(height: 14),
                  _buildChallengeBanner(),
                  const SizedBox(height: 14),
                  Expanded(
                    child: KeyedSubtree(
                      key: ValueKey('g_${_currentChallengeIndex}_r_${_currentRound}_a_$_attemptCounter'),
                      child: _buildCurrentChallengeWidget(),
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

  Widget _buildLiveStatsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Acertos
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppTheme.rewardGreen, size: 18),
              const SizedBox(width: 6),
              Text(
                '$_hits Acertos',
                style: GoogleFonts.orbitron(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.rewardGreen,
                ),
              ),
            ],
          ),
          // Divisor
          Container(height: 16, width: 1, color: AppTheme.surfaceBorder),
          // Erros
          Row(
            children: [
              const Icon(Icons.cancel_rounded, color: AppTheme.alertPink, size: 18),
              const SizedBox(width: 6),
              Text(
                '$_misses Erros',
                style: GoogleFonts.orbitron(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.alertPink,
                ),
              ),
            ],
          ),
          // Divisor
          Container(height: 16, width: 1, color: AppTheme.surfaceBorder),
          // Pontos XP
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: AppTheme.habitAmber, size: 20),
              const SizedBox(width: 4),
              Text(
                '$_currentSessionScore XP',
                style: GoogleFonts.orbitron(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.habitAmber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameBatteryProgression() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Jogo ${_currentChallengeIndex + 1} de ${_challenges.length}: ${_activeChallenge.title}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              'Rodada $_currentRound de ${_activeChallenge.totalRounds}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.focusCyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(_challenges.length, (index) {
            final isDone = index < _currentChallengeIndex;
            final isCurrent = index == _currentChallengeIndex;

            Color barColor = AppTheme.surfaceElevated;
            if (isDone) barColor = AppTheme.rewardGreen;
            if (isCurrent) barColor = AppTheme.focusCyan;

            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppTheme.focusCyan.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildChallengeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.focusCyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIconForChallenge(_activeChallenge.type),
              color: AppTheme.focusCyan,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _activeChallenge.title,
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  _activeChallenge.cognitiveDomain,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForChallenge(ChallengeType type) {
    switch (type) {
      case ChallengeType.stroopReflex:
        return Icons.psychology_rounded;
      case ChallengeType.flashMatrix:
        return Icons.grid_view_rounded;
      case ChallengeType.digitSequence:
        return Icons.pin_rounded;
    }
  }

  Widget _buildCurrentChallengeWidget() {
    switch (_activeChallenge.type) {
      case ChallengeType.stroopReflex:
        return StroopReflexGame(
          currentRound: _currentRound,
          totalRounds: _activeChallenge.totalRounds,
          onRoundComplete: _onRoundSuccess,
          onFailed: _onRoundFail,
        );
      case ChallengeType.flashMatrix:
        return FlashMatrixWaveChallenge(
          currentRound: _currentRound,
          totalRounds: _activeChallenge.totalRounds,
          onRoundComplete: _onRoundSuccess,
          onFailed: _onRoundFail,
        );
      case ChallengeType.digitSequence:
        return DigitSequenceGame(
          currentRound: _currentRound,
          totalRounds: _activeChallenge.totalRounds,
          onRoundComplete: _onRoundSuccess,
          onFailed: _onRoundFail,
        );
    }
  }

  Widget _buildCompletionView() {
    final totalAttempts = _hits + _misses;
    final precision = totalAttempts > 0 ? ((_hits / totalAttempts) * 100).round() : 100;
    final weeklyXp = widget.progressService.progress.weeklyXp;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.rewardGreen.withValues(alpha: 0.15),
                  border: Border.all(color: AppTheme.rewardGreen, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.rewardGreen.withValues(alpha: 0.35),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 50,
                  color: AppTheme.rewardGreen,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'FASE ${widget.phaseLevel} SUPERADA!',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Você completou as 3 baterias de desafios cognitivos.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              // Card de Desempenho (Acertos, Erros, Precisão)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Acertos', '$_hits', AppTheme.rewardGreen),
                    Container(height: 30, width: 1, color: AppTheme.surfaceBorder),
                    _buildStatItem('Erros', '$_misses', AppTheme.alertPink),
                    Container(height: 30, width: 1, color: AppTheme.surfaceBorder),
                    _buildStatItem('Precisão', '$precision%', AppTheme.focusCyan),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Card de XP e Liga
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.prestigeGold.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bolt_rounded, color: AppTheme.habitAmber, size: 28),
                        const SizedBox(width: 6),
                        Text(
                          '+$_finalAwardedXp XP Conquistados',
                          style: GoogleFonts.orbitron(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.habitAmber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Total Semanal na Liga: $weeklyXp XP (Subindo de posição!)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.rewardGreen,
                    foregroundColor: const Color(0xFF0A0F1D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'AVANÇAR NA TRILHA',
                    style: GoogleFonts.orbitron(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
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

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
