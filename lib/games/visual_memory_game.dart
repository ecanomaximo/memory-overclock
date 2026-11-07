import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class MemoryCardItem {
  final int id;
  final String label;
  final IconData icon;
  final Color accentColor;
  bool isFaceUp;
  bool isMatched;

  MemoryCardItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.accentColor,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}

class VisualMemoryMatchGame extends StatefulWidget {
  final int currentRound;
  final int totalRounds;
  final int phaseLevel;
  final VoidCallback onRoundComplete;
  final VoidCallback onFailed;

  const VisualMemoryMatchGame({
    super.key,
    required this.currentRound,
    required this.totalRounds,
    this.phaseLevel = 1,
    required this.onRoundComplete,
    required this.onFailed,
  });

  @override
  State<VisualMemoryMatchGame> createState() => _VisualMemoryMatchGameState();
}

class _VisualMemoryMatchGameState extends State<VisualMemoryMatchGame> {
  static const List<Map<String, dynamic>> _iconPool = [
    {'label': 'Cérebro', 'icon': Icons.psychology_rounded, 'color': AppTheme.primaryNeuroCyan},
    {'label': 'Relâmpago', 'icon': Icons.bolt_rounded, 'color': Color(0xFFFFD600)},
    {'label': 'Foguete', 'icon': Icons.rocket_launch_rounded, 'color': Color(0xFFFF6D00)},
    {'label': 'Diamante', 'icon': Icons.diamond_rounded, 'color': Color(0xFF2979FF)},
    {'label': 'Estrela', 'icon': Icons.star_rounded, 'color': AppTheme.gold},
    {'label': 'Alvo', 'icon': Icons.crisis_alert_rounded, 'color': Color(0xFFFF334B)},
    {'label': 'Lâmpada', 'icon': Icons.lightbulb_rounded, 'color': Color(0xFF00E676)},
    {'label': 'Fogo', 'icon': Icons.local_fire_department_rounded, 'color': Color(0xFFFF5252)},
  ];

  late List<MemoryCardItem> _cards;
  late int _totalPairs;
  int? _firstFlippedIndex;
  bool _isProcessingMatch = false;
  int _pairsFound = 0;

  bool get _isTutorial => widget.currentRound == 1;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  void _startRound() {
    _firstFlippedIndex = null;
    _isProcessingMatch = false;
    _pairsFound = 0;

    // Escala por nível:
    // Nível 1 a 3: 4 pares (8 cartas - fácil)
    // Nível 4 a 6: 6 pares (12 cartas - intermediário)
    // Nível 7+: 8 pares (16 cartas - avançado)
    _totalPairs = widget.phaseLevel <= 3 ? 4 : (widget.phaseLevel <= 6 ? 6 : 8);
    final activePool = _iconPool.take(_totalPairs).toList();

    final list = <MemoryCardItem>[];
    int cardId = 0;

    for (final item in activePool) {
      list.add(
        MemoryCardItem(
          id: cardId++,
          label: item['label'] as String,
          icon: item['icon'] as IconData,
          accentColor: item['color'] as Color,
        ),
      );
      list.add(
        MemoryCardItem(
          id: cardId++,
          label: item['label'] as String,
          icon: item['icon'] as IconData,
          accentColor: item['color'] as Color,
        ),
      );
    }

    list.shuffle();
    _cards = list;
  }

  void _onCardTap(int index) {
    if (_isProcessingMatch) return;
    final card = _cards[index];
    if (card.isFaceUp || card.isMatched) return;

    setState(() {
      card.isFaceUp = true;
    });

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
    } else {
      final firstIndex = _firstFlippedIndex!;
      final firstCard = _cards[firstIndex];

      if (firstCard.label == card.label) {
        firstCard.isMatched = true;
        card.isMatched = true;
        _firstFlippedIndex = null;
        _pairsFound++;

        if (_pairsFound == _totalPairs) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              widget.onRoundComplete();
            }
          });
        }
      } else {
        _isProcessingMatch = true;
        Future.delayed(const Duration(milliseconds: 650), () {
          if (!mounted) return;
          setState(() {
            firstCard.isFaceUp = false;
            card.isFaceUp = false;
            _firstFlippedIndex = null;
            _isProcessingMatch = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isTutorial)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.cardDeepSlate,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primaryNeuroCyan.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppTheme.primaryNeuroCyan),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'RODADA 1 (TUTORIAL): Toque nas cartas para encontrar os pares de imagens idênticas.',
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
        const SizedBox(height: 8),
        Text(
          'MEMÓRIA VISUAL: $_pairsFound / $_totalPairs PARES',
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: AppTheme.primaryNeuroCyan,
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  return _buildCardItem(_cards[index], index);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCardItem(MemoryCardItem card, int index) {
    final isRevealed = card.isFaceUp || card.isMatched;

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isRevealed
              ? (card.isMatched
                  ? card.accentColor.withValues(alpha: 0.2)
                  : AppTheme.cardDeepSlate)
              : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRevealed
                ? (card.isMatched ? card.accentColor : AppTheme.primaryNeuroCyan)
                : AppTheme.surfaceBorder,
            width: isRevealed ? 2.0 : 1.2,
          ),
          boxShadow: isRevealed
              ? [
                  BoxShadow(
                    color: (card.isMatched ? card.accentColor : AppTheme.primaryNeuroCyan)
                        .withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isRevealed
              ? Icon(
                  card.icon,
                  size: 34,
                  color: card.accentColor,
                )
              : Icon(
                  Icons.psychology_alt_outlined,
                  size: 26,
                  color: AppTheme.textMuted.withValues(alpha: 0.5),
                ),
        ),
      ),
    );
  }
}
