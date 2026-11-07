import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class StroopColorItem {
  final String name;
  final Color color;

  const StroopColorItem(this.name, this.color);
}

class StroopStimulus {
  final String word;
  final Color displayColor;
  final String actualColorName;
  final bool isMatch;

  const StroopStimulus({
    required this.word,
    required this.displayColor,
    required this.actualColorName,
    required this.isMatch,
  });
}

class StroopEngine {
  static List<StroopColorItem> getPaletteForLevel(int level) {
    if (level <= 3) {
      // Níveis 1 a 3: As 4 cores primárias mais fáceis e universais
      return const [
        StroopColorItem('VERMELHO', Color(0xFFFF334B)),
        StroopColorItem('AZUL', Color(0xFF2979FF)),
        StroopColorItem('VERDE', Color(0xFF00E676)),
        StroopColorItem('AMARELO', Color(0xFFFFD600)),
      ];
    } else if (level <= 6) {
      // Níveis 4 a 6: Intermediário (+ Laranja, Roxo)
      return const [
        StroopColorItem('VERMELHO', Color(0xFFFF334B)),
        StroopColorItem('AZUL', Color(0xFF2979FF)),
        StroopColorItem('VERDE', Color(0xFF00E676)),
        StroopColorItem('AMARELO', Color(0xFFFFD600)),
        StroopColorItem('LARANJA', Color(0xFFFF7A00)),
        StroopColorItem('ROXO', Color(0xFFB026FF)),
      ];
    } else {
      // Níveis 7+: Avançado (+ Ciano, Menta, Magenta para máximo esforço cognitivo)
      return const [
        StroopColorItem('VERMELHO', Color(0xFFFF334B)),
        StroopColorItem('AZUL', Color(0xFF2979FF)),
        StroopColorItem('VERDE', Color(0xFF00E676)),
        StroopColorItem('AMARELO', Color(0xFFFFD600)),
        StroopColorItem('LARANJA', Color(0xFFFF7A00)),
        StroopColorItem('ROXO', Color(0xFFB026FF)),
        StroopColorItem('CIANO', Color(0xFF00D2FF)),
        StroopColorItem('MENTA', Color(0xFF00E599)),
        StroopColorItem('MAGENTA', Color(0xFFFF2A85)),
      ];
    }
  }

  static StroopStimulus generateStimulus({
    required int round,
    int level = 1,
    Random? random,
  }) {
    final rng = random ?? Random();
    final isMatch = rng.nextBool();
    final palette = getPaletteForLevel(level);

    final wordItem = palette[rng.nextInt(palette.length)];
    if (isMatch) {
      return StroopStimulus(
        word: wordItem.name,
        displayColor: wordItem.color,
        actualColorName: wordItem.name,
        isMatch: true,
      );
    } else {
      final availableColors = palette.where((item) => item.name != wordItem.name).toList();
      final colorItem = availableColors[rng.nextInt(availableColors.length)];
      return StroopStimulus(
        word: wordItem.name,
        displayColor: colorItem.color,
        actualColorName: colorItem.name,
        isMatch: false,
      );
    }
  }

  static int getDurationMsForRound(int round, int totalRounds, {double timeMultiplier = 1.0, int level = 1}) {
    final levelSpeedAdjustment = min(15000, (level - 1) * 1500);
    final baseMs = (round <= 1)
        ? 90000 // 90 segundos na Rodada 1
        : max(45000, (75000 - (((round - 1) / (totalRounds - 1)) * 15000) - levelSpeedAdjustment).round());
    return (baseMs * timeMultiplier).round();
  }
}

class StroopReflexGame extends StatefulWidget {
  final int currentRound;
  final int totalRounds;
  final int phaseLevel;
  final double timeMultiplier;
  final VoidCallback onRoundComplete;
  final VoidCallback onFailed;

  const StroopReflexGame({
    super.key,
    required this.currentRound,
    required this.totalRounds,
    this.phaseLevel = 1,
    this.timeMultiplier = 1.0,
    required this.onRoundComplete,
    required this.onFailed,
  });

  @override
  State<StroopReflexGame> createState() => _StroopReflexGameState();
}

class _StroopReflexGameState extends State<StroopReflexGame> {
  late StroopStimulus _currentStimulus;
  Timer? _roundTimer;
  Timer? _ticker;
  double _timeRemainingPercent = 1.0;
  int _remainingSeconds = 90;
  bool _answered = false;

  bool get _isTutorial => widget.currentRound == 1;

  @override
  void initState() {
    super.initState();
    _startStimulus();
  }

  @override
  void didUpdateWidget(covariant StroopReflexGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRound != widget.currentRound) {
      _startStimulus();
    }
  }

  void _startStimulus() {
    _answered = false;
    _currentStimulus = StroopEngine.generateStimulus(
      round: widget.currentRound,
      level: widget.phaseLevel,
    );
    final durationMs = StroopEngine.getDurationMsForRound(
      widget.currentRound,
      widget.totalRounds,
      timeMultiplier: widget.timeMultiplier,
      level: widget.phaseLevel,
    );
    _remainingSeconds = (durationMs / 1000).ceil();

    const stepMs = 50;
    final totalSteps = durationMs / stepMs;
    int currentStep = 0;

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: stepMs), (timer) {
      currentStep++;
      if (mounted) {
        setState(() {
          _timeRemainingPercent = max(0.0, 1.0 - (currentStep / totalSteps));
          _remainingSeconds = max(0, ((durationMs - (currentStep * stepMs)) / 1000).ceil());
        });
      }
    });

    _roundTimer?.cancel();
    _roundTimer = Timer(Duration(milliseconds: durationMs), () {
      _ticker?.cancel();
      if (!_answered && mounted) {
        widget.onFailed();
      }
    });
  }

  void _submitAnswer(bool userSaysMatch) {
    if (_answered) return;
    _answered = true;
    _roundTimer?.cancel();
    _ticker?.cancel();

    if (userSaysMatch == _currentStimulus.isMatch) {
      widget.onRoundComplete();
    } else {
      widget.onFailed();
    }
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isTutorial)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryNeuroCyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryNeuroCyan.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.primaryNeuroCyan, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'RODADA 1 (TUTORIAL): A COR da tinta bate com o NOME escrito? Foque na cor real!',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryNeuroCyan,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _timeRemainingPercent,
            backgroundColor: AppTheme.cardDeepSlate,
            valueColor: AlwaysStoppedAnimation<Color>(
              _timeRemainingPercent > 0.3 ? AppTheme.primaryNeuroCyan : AppTheme.accentSolarAmber,
            ),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TEMPO DE RESOLUÇÃO',
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMutedSlate, fontWeight: FontWeight.w600),
            ),
            Text(
              '${_remainingSeconds}s restantes',
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _remainingSeconds > 20 ? AppTheme.primaryNeuroCyan : AppTheme.accentSolarAmber,
              ),
            ),
          ],
        ),
        const Spacer(),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320, minWidth: 200),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
              decoration: BoxDecoration(
                color: AppTheme.cardDeepSlate,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _currentStimulus.displayColor.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _currentStimulus.displayColor.withValues(alpha: 0.15),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Text(
                _currentStimulus.word,
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: _currentStimulus.displayColor,
                  letterSpacing: 3.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'A cor da tinta corresponde à palavra?',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppTheme.textMutedSlate,
          ),
        ),
        const Spacer(),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _submitAnswer(false),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    label: Text(
                      'NÃO (DIFERENTE)',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: const Color(0xFFFF4D4D),
                      side: const BorderSide(color: Color(0xFFFF4D4D), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _submitAnswer(true),
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: Text(
                      'SIM (CORRETO)',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentBioGreen,
                      foregroundColor: const Color(0xFF0A0F1D),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
