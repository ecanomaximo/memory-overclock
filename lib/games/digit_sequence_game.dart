import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class DigitSequenceEngine {
  static List<int> generateSequence({
    required int length,
    Random? random,
  }) {
    final rng = random ?? Random();
    return List.generate(length, (_) => rng.nextInt(10));
  }

  static int getSequenceLengthForRound(int round, int totalRounds) {
    if (round <= 1) return 3;
    // Escala de 3 até 7 dígitos
    final step = min(4, ((round - 1) * 4 / (totalRounds - 1)).round());
    return 3 + step;
  }

  static int getDisplayDurationMs(int round) {
    if (round <= 1) return 1200;
    if (round <= 3) return 900;
    return 700;
  }
}

class DigitSequenceGame extends StatefulWidget {
  final int currentRound;
  final int totalRounds;
  final VoidCallback onRoundComplete;
  final VoidCallback onFailed;

  const DigitSequenceGame({
    super.key,
    required this.currentRound,
    required this.totalRounds,
    required this.onRoundComplete,
    required this.onFailed,
  });

  @override
  State<DigitSequenceGame> createState() => _DigitSequenceGameState();
}

class _DigitSequenceGameState extends State<DigitSequenceGame> {
  late List<int> _targetSequence;
  final List<int> _enteredDigits = [];
  bool _isShowingSequence = true;
  int _activeDigitIndex = 0;
  Timer? _sequenceTimer;

  bool get _isTutorial => widget.currentRound == 1;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  void _startRound() {
    final length = DigitSequenceEngine.getSequenceLengthForRound(
      widget.currentRound,
      widget.totalRounds,
    );
    _targetSequence = DigitSequenceEngine.generateSequence(length: length);
    _enteredDigits.clear();
    _isShowingSequence = true;
    _activeDigitIndex = 0;

    _runSequenceDisplay();
  }

  void _runSequenceDisplay() {
    final interval = Duration(
      milliseconds: DigitSequenceEngine.getDisplayDurationMs(widget.currentRound),
    );

    _sequenceTimer?.cancel();
    _sequenceTimer = Timer.periodic(interval, (timer) {
      if (!mounted) return;
      if (_activeDigitIndex < _targetSequence.length - 1) {
        setState(() {
          _activeDigitIndex++;
        });
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _isShowingSequence = false;
            });
          }
        });
      }
    });
  }

  void _onDigitPressed(int digit) {
    if (_isShowingSequence) return;

    setState(() {
      _enteredDigits.add(digit);
    });

    final currentIndex = _enteredDigits.length - 1;
    if (_enteredDigits[currentIndex] != _targetSequence[currentIndex]) {
      // Erro imediato
      widget.onFailed();
      return;
    }

    if (_enteredDigits.length == _targetSequence.length) {
      widget.onRoundComplete();
    }
  }

  void _onBackspace() {
    if (_enteredDigits.isNotEmpty && !_isShowingSequence) {
      setState(() {
        _enteredDigits.removeLast();
      });
    }
  }

  @override
  void dispose() {
    _sequenceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isTutorial)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
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
                    'RODADA 1 (TUTORIAL): Memorize os dígitos em ordem e digite-os no teclado abaixo.',
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
        const SizedBox(height: 10),
        Text(
          _isShowingSequence ? 'MEMORIZE A SEQUÊNCIA' : 'DIGITE A SEQUÊNCIA',
          style: GoogleFonts.orbitron(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: _isShowingSequence ? AppTheme.accentSolarAmber : AppTheme.accentBioGreen,
          ),
        ),
        const SizedBox(height: 20),
        _buildDisplayArea(),
        const Spacer(),
        if (!_isShowingSequence) _buildKeypad(),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDisplayArea() {
    if (_isShowingSequence) {
      final currentDigit = _targetSequence[_activeDigitIndex];
      return Container(
        width: 110,
        height: 130,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.cardDeepSlate,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryNeuroCyan, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryNeuroCyan.withValues(alpha: 0.25),
              blurRadius: 25,
            ),
          ],
        ),
        child: Text(
          '$currentDigit',
          style: GoogleFonts.orbitron(
            fontSize: 64,
            fontWeight: FontWeight.w900,
            color: AppTheme.primaryNeuroCyan,
          ),
        ),
      );
    }

    // Input slots
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_targetSequence.length, (index) {
        final hasDigit = index < _enteredDigits.length;
        final digit = hasDigit ? _enteredDigits[index] : null;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 44,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.cardDeepSlate,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasDigit ? AppTheme.accentBioGreen : AppTheme.cardBorderMuted,
              width: hasDigit ? 2 : 1,
            ),
          ),
          child: Text(
            digit != null ? '$digit' : '_',
            style: GoogleFonts.orbitron(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: hasDigit ? AppTheme.accentBioGreen : AppTheme.textMutedSlate,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < 3; row++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var col = 1; col <= 3; col++)
                  _buildKeyButton((row * 3) + col),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(Icons.backspace_outlined, _onBackspace),
              _buildKeyButton(0),
              const SizedBox(width: 74), // Placeholder para balancear layout
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyButton(int digit) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: AppTheme.cardDeepSlate,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _onDigitPressed(digit),
          child: Container(
            width: 62,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.cardBorderMuted),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$digit',
              style: GoogleFonts.orbitron(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryLight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: AppTheme.cardDeepSlate,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: 62,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.cardBorderMuted),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.textMutedSlate, size: 20),
          ),
        ),
      ),
    );
  }
}
