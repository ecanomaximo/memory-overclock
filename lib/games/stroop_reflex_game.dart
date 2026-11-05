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
  static const List<StroopColorItem> colorPalette = [
    StroopColorItem('CIANO', AppTheme.primaryNeuroCyan),
    StroopColorItem('MENTA', AppTheme.accentBioGreen),
    StroopColorItem('ÂMBAR', AppTheme.accentSolarAmber),
    StroopColorItem('MAGENTA', Color(0xFFFF2A85)),
  ];

  static StroopStimulus generateStimulus({
    required int round,
    Random? random,
  }) {
    final rng = random ?? Random();
    final isMatch = rng.nextBool();

    final wordItem = colorPalette[rng.nextInt(colorPalette.length)];
    if (isMatch) {
      return StroopStimulus(
        word: wordItem.name,
        displayColor: wordItem.color,
        actualColorName: wordItem.name,
        isMatch: true,
      );
    } else {
      final availableColors = colorPalette.where((item) => item.name != wordItem.name).toList();
      final colorItem = availableColors[rng.nextInt(availableColors.length)];
      return StroopStimulus(
        word: wordItem.name,
        displayColor: colorItem.color,
        actualColorName: colorItem.name,
        isMatch: false,
      );
    }
  }

  static int getDurationMsForRound(int round, int totalRounds) {
    if (round <= 1) return 90000; // 90 segundos (1m30s) na Rodada 1
    final progress = (round - 1) / (totalRounds - 1);
    // Varia suavemente de 75000ms (1m15s) até 60000ms (1 minuto)
    return (75000 - (progress * 15000)).round();
  }
}

class StroopReflexGame extends StatefulWidget {
  final int currentRound;
  final int totalRounds;
  final VoidCallback onRoundComplete;
  final VoidCallback onFailed;

  const StroopReflexGame({
    super.key,
    required this.currentRound,
    required this.totalRounds,
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
    _currentStimulus = StroopEngine.generateStimulus(round: widget.currentRound);
    final durationMs = StroopEngine.getDurationMsForRound(widget.currentRound, widget.totalRounds);
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          decoration: BoxDecoration(
            color: AppTheme.cardDeepSlate,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _currentStimulus.displayColor.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _currentStimulus.displayColor.withValues(alpha: 0.15),
                blurRadius: 30,
              ),
            ],
          ),
          child: Text(
            _currentStimulus.word,
            style: GoogleFonts.orbitron(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: _currentStimulus.displayColor,
              letterSpacing: 4.0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'A cor da tinta corresponde à palavra?',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.textMutedSlate,
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _submitAnswer(false),
                icon: const Icon(Icons.close_rounded),
                label: Text(
                  'NÃO (DIFERENTE)',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: const Color(0xFFFF4D4D),
                  side: const BorderSide(color: Color(0xFFFF4D4D), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _submitAnswer(true),
                icon: const Icon(Icons.check_rounded),
                label: Text(
                  'SIM (CORRETO)',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBioGreen,
                  foregroundColor: const Color(0xFF0A0F1D),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
