import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class ColorItem {
  final String label;   // Texto escrito (ex: 'AZUL')
  final Color displayColor; // Cor visual real
  final String colorName;   // Nome da cor real (para conferência)

  ColorItem({
    required this.label,
    required this.displayColor,
    required this.colorName,
  });
}

enum ColorGameState { intro, showing, input, won, lost }

class ColorClashGame extends StatefulWidget {
  final int level;
  final ProgressService progressService;

  const ColorClashGame({
    super.key,
    required this.level,
    required this.progressService,
  });

  @override
  State<ColorClashGame> createState() => _ColorClashGameState();
}

class _ColorClashGameState extends State<ColorClashGame> {
  static const List<Map<String, dynamic>> availableColors = [
    {'name': 'AZUL', 'color': AppTheme.neonCyan},
    {'name': 'ROSA', 'color': AppTheme.neonPink},
    {'name': 'VERDE', 'color': AppTheme.neonGreen},
    {'name': 'ROXO', 'color': AppTheme.neonPurple},
    {'name': 'AMARELO', 'color': AppTheme.gold},
  ];

  late int _sequenceLength;
  late int _displaySpeedMs;

  final List<ColorItem> _targetSequence = [];
  final List<String> _userSelectedColors = [];

  ColorGameState _state = ColorGameState.intro;
  int _currentShowingIndex = -1;
  Timer? _sequenceTimer;

  @override
  void initState() {
    super.initState();
    _setupDifficulty();
    _startRound();
  }

  void _setupDifficulty() {
    final lvl = widget.level;
    if (lvl <= 3) {
      _sequenceLength = 3;
      _displaySpeedMs = 1200;
    } else if (lvl <= 6) {
      _sequenceLength = 4;
      _displaySpeedMs = 950;
    } else {
      _sequenceLength = 5;
      _displaySpeedMs = 750;
    }
  }

  void _startRound() {
    _targetSequence.clear();
    _userSelectedColors.clear();
    _currentShowingIndex = -1;

    final random = Random();
    for (int i = 0; i < _sequenceLength; i++) {
      final actualColorData = availableColors[random.nextInt(availableColors.length)];
      // Conflito Stroop: O texto pode ser diferente da cor visual
      final textData = availableColors[random.nextInt(availableColors.length)];

      _targetSequence.add(
        ColorItem(
          label: textData['name'] as String,
          displayColor: actualColorData['color'] as Color,
          colorName: actualColorData['name'] as String,
        ),
      );
    }

    setState(() {
      _state = ColorGameState.showing;
    });

    _playSequence();
  }

  void _playSequence() {
    int step = 0;
    _sequenceTimer?.cancel();
    _sequenceTimer = Timer.periodic(Duration(milliseconds: _displaySpeedMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (step < _targetSequence.length) {
        setState(() {
          _currentShowingIndex = step;
        });
        step++;
      } else {
        timer.cancel();
        setState(() {
          _currentShowingIndex = -1;
          _state = ColorGameState.input;
        });
      }
    });
  }

  void _onColorTap(String colorName) {
    if (_state != ColorGameState.input) return;

    final currentIndex = _userSelectedColors.length;
    final expectedColorName = _targetSequence[currentIndex].colorName;

    if (colorName == expectedColorName) {
      setState(() {
        _userSelectedColors.add(colorName);
      });

      if (_userSelectedColors.length == _targetSequence.length) {
        // Venceu o desafio
        setState(() {
          _state = ColorGameState.won;
        });

        final earnedXp = 45 + (widget.level * 10);
        widget.progressService.recordGameCompleted(
          levelCompleted: widget.level,
          earnedXp: earnedXp,
        );
      }
    } else {
      // Errou a cor
      setState(() {
        _state = ColorGameState.lost;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fase ${widget.level} • Desafio de Cores',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              _buildRuleCard(),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: _buildCenterDisplay(),
                ),
              ),
              const SizedBox(height: 20),
              _buildInputPalette(),
              const SizedBox(height: 16),
              _buildBottomAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology, color: AppTheme.neonPurple, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'REGRA: Memorize a COR VISUAL real do texto, ignore a palavra escrita!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterDisplay() {
    if (_state == ColorGameState.showing) {
      if (_currentShowingIndex >= 0 && _currentShowingIndex < _targetSequence.length) {
        final current = _targetSequence[_currentShowingIndex];
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Container(
            key: ValueKey(_currentShowingIndex),
            width: double.infinity,
            height: 180,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: current.displayColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: current.displayColor.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Text(
              current.label,
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: current.displayColor,
                letterSpacing: 2,
              ),
            ),
          ),
        );
      }
    }

    if (_state == ColorGameState.input) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Toque nas cores na ordem que você viu:',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_targetSequence.length, (index) {
              final isAnswered = index < _userSelectedColors.length;
              Color circleColor = AppTheme.surfaceElevated;

              if (isAnswered) {
                final chosenName = _userSelectedColors[index];
                final match = availableColors.firstWhere((c) => c['name'] == chosenName);
                circleColor = match['color'] as Color;
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor,
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: isAnswered
                    ? const Icon(Icons.check, size: 18, color: Colors.black)
                    : null,
              );
            }),
          ),
        ],
      );
    }

    if (_state == ColorGameState.won) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.neonGreen),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, color: AppTheme.neonGreen, size: 54),
            SizedBox(height: 12),
            Text(
              'FOCO VISUAL PERFEITO!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppTheme.neonGreen,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Você venceu o conflito Stroop sem se distrair.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (_state == ColorGameState.lost) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.neonPink),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel, color: AppTheme.neonPink, size: 54),
            SizedBox(height: 12),
            Text(
              'COR INCORRETA!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppTheme.neonPink,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Lembre-se: foque na cor da luz, não na palavra!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInputPalette() {
    if (_state != ColorGameState.input) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: availableColors.map((colorData) {
        final name = colorData['name'] as String;
        final color = colorData['color'] as Color;

        return GestureDetector(
          onTap: () => _onColorTap(name),
          child: Container(
            width: 90,
            height: 54,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Center(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomAction() {
    if (_state == ColorGameState.won) {
      final earnedXp = 45 + (widget.level * 10);
      return Column(
        children: [
          Text(
            '+$earnedXp XP Ganho!',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.gold,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonGreen,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CONTINUAR NA TRILHA',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      );
    }

    if (_state == ColorGameState.lost) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.surfaceElevated,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.refresh),
          label: const Text(
            'TENTAR NOVAMENTE',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          onPressed: _startRound,
        ),
      );
    }

    return const SizedBox(height: 52);
  }
}
