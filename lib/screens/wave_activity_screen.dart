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
  final int activityNumber;
  final ProgressService progressService;
  final CadenceService cadenceService;
  final int roundsPerChallenge;

  const WaveActivityScreen({
    super.key,
    required this.activityNumber,
    required this.progressService,
    required this.cadenceService,
    this.roundsPerChallenge = 5,
  });

  @override
  State<WaveActivityScreen> createState() => _WaveActivityScreenState();
}

class _WaveActivityScreenState extends State<WaveActivityScreen> {
  late final List<WaveChallenge> _challenges;
  int _currentChallengeIndex = 0;
  int _currentRound = 1;
  int _challengeLives = 3;
  bool _isWaveCompleted = false;
  int _earnedXp = 0;

  @override
  void initState() {
    super.initState();
    _challenges = WaveChallenge.createDefaultWave(
      roundsPerChallenge: widget.roundsPerChallenge,
    );
  }

  WaveChallenge get _activeChallenge => _challenges[_currentChallengeIndex];

  void _onRoundSuccess() {
    if (_currentRound < _activeChallenge.totalRounds) {
      setState(() {
        _currentRound++;
      });
    } else {
      // Desafio concluído!
      _onChallengeComplete();
    }
  }

  void _onRoundFail() {
    setState(() {
      _challengeLives--;
    });

    if (_challengeLives <= 0) {
      _showFailureDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ops! Tentativa falhou. Você ainda tem $_challengeLives vida(s).',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: AppTheme.alertPink,
          duration: const Duration(seconds: 2),
        ),
      );
      // Reinicia a rodada atual
      setState(() {});
    }
  }

  void _onChallengeComplete() {
    if (_currentChallengeIndex < _challenges.length - 1) {
      setState(() {
        _currentChallengeIndex++;
        _currentRound = 1;
        _challengeLives = 3;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚡ ${_challenges[_currentChallengeIndex - 1].title} Concluído! Próximo: ${_activeChallenge.title}',
            style: GoogleFonts.inter(
              color: const Color(0xFF0A0F1D),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppTheme.accentBioGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Onda completa!
      _finishWave();
    }
  }

  void _finishWave() {
    final isVip = widget.progressService.progress.isVip;
    const baseReward = 150;
    _earnedXp = isVip ? (baseReward * 1.5).round() : baseReward;

    // Consome atividade na cadência de 5h
    widget.cadenceService.consumeActivity();

    // Adiciona XP no progresso
    widget.progressService.recordGameCompleted(
      levelCompleted: widget.progressService.progress.currentLevel,
      earnedXp: _earnedXp,
    );

    setState(() {
      _isWaveCompleted = true;
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
          'Você não conseguiu superar ${_activeChallenge.title}. Deseja reiniciar este desafio da onda?',
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
              });
            },
            child: const Text('Reiniciar Desafio'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isWaveCompleted) {
      return _buildCompletionView();
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text(
          'ATIVIDADE ${widget.activityNumber} • ONDA',
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              _buildWaveProgressionBar(),
              const SizedBox(height: 16),
              _buildChallengeHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: KeyedSubtree(
                  key: ValueKey('c_${_currentChallengeIndex}_r_$_currentRound'),
                  child: _buildCurrentChallengeWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaveProgressionBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Onda: Desafio ${_currentChallengeIndex + 1} de ${_challenges.length}',
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

  Widget _buildChallengeHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.focusCyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconForChallenge(_activeChallenge.type),
              color: AppTheme.focusCyan,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _activeChallenge.title,
                  style: GoogleFonts.orbitron(
                    fontSize: 15,
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
      case ChallengeType.flashMatrix:
        return Icons.grid_view_rounded;
      case ChallengeType.stroopReflex:
        return Icons.psychology_rounded;
      case ChallengeType.digitSequence:
        return Icons.pin_rounded;
    }
  }

  Widget _buildCurrentChallengeWidget() {
    switch (_activeChallenge.type) {
      case ChallengeType.flashMatrix:
        return FlashMatrixWaveChallenge(
          currentRound: _currentRound,
          totalRounds: _activeChallenge.totalRounds,
          onRoundComplete: _onRoundSuccess,
          onFailed: _onRoundFail,
        );
      case ChallengeType.stroopReflex:
        return StroopReflexGame(
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.rewardGreen.withValues(alpha: 0.15),
                  border: Border.all(color: AppTheme.rewardGreen, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.rewardGreen.withValues(alpha: 0.35),
                      blurRadius: 35,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 60,
                  color: AppTheme.rewardGreen,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'ONDA CONCLUÍDA!',
                style: GoogleFonts.orbitron(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Você superou os 3 desafios da atividade com maestria cognitiva.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: AppTheme.habitAmber, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '+$_earnedXp XP',
                      style: GoogleFonts.orbitron(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.habitAmber,
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
                    'VOLTAR PARA A TRILHA',
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
    );
  }
}
