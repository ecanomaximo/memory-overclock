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
    if (round <= 1) return 1800;
    if (round <= 3) return 1300;
    return 1000;
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
  bool _isDigitBlinking = false;
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
    _isDigitBlinking = false;
    _activeDigitIndex = 0;

    _runSequenceDisplay();
  }

  void _runSequenceDisplay() {
    final intervalMs = DigitSequenceEngine.getDisplayDurationMs(widget.currentRound);

    _sequenceTimer?.cancel();
    _sequenceTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!mounted) return;
      if (_activeDigitIndex < _targetSequence.length - 1) {
        // Pisca o dígito para dar feedback visual inconfundível mesmo em repetições
        setState(() {
          _isDigitBlinking = true;
        });

        Future.delayed(const Duration(milliseconds: 160), () {
          if (!mounted) return;
          setState(() {
            _activeDigitIndex++;
            _isDigitBlinking = false;
          });
        });
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 400), () {
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
        const SizedBox(height: 16),
        _buildDisplayArea(),
        const Spacer(),
        if (!_isShowingSequence)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: _buildKeypad(),
            ),
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDisplayArea() {
    if (_isShowingSequence) {
      final currentDigit = _targetSequence[_activeDigitIndex];
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 140),
            opacity: _isDigitBlinking ? 0.05 : 1.0,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 140),
              scale: _isDigitBlinking ? 0.82 : 1.0,
              child: Container(
                width: 96,
                height: 110,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.cardDeepSlate,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _isDigitBlinking ? Colors.transparent : AppTheme.primaryNeuroCyan,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryNeuroCyan.withValues(alpha: _isDigitBlinking ? 0.0 : 0.35),
                      blurRadius: 22,
                    ),
                  ],
                ),
                child: Text(
                  '$currentDigit',
                  style: GoogleFonts.orbitron(
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryNeuroCyan,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Dígito ${_activeDigitIndex + 1} de ${_targetSequence.length}',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      );
    }

    // Input slots
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_targetSequence.length, (index) {
          final hasDigit = index < _enteredDigits.length;
          final digit = hasDigit ? _enteredDigits[index] : null;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 40,
            height: 48,
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: hasDigit ? AppTheme.accentBioGreen : AppTheme.textMutedSlate,
              ),
            ),
          );
        }),
      ),
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
            width: 58,
            height: 48,
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
            width: 58,
            height: 48,
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
