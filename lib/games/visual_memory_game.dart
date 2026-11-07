import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class MemoryEmojiItem {
  final String emoji;
  final String label;
  final Color glowColor;

  const MemoryEmojiItem(this.emoji, this.label, this.glowColor);
}

class MemoryCardItem {
  final int id;
  final String emoji;
  final String label;
  final Color accentColor;
  bool isFaceUp;
  bool isMatched;

  MemoryCardItem({
    required this.id,
    required this.emoji,
    required this.label,
    required this.accentColor,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}

class VisualMemoryEngine {
  static const List<MemoryEmojiItem> emojiPool = [
    MemoryEmojiItem('🧠', 'Cérebro', Color(0xFF00E5FF)),
    MemoryEmojiItem('⚡', 'Raio', Color(0xFFFFD600)),
    MemoryEmojiItem('🚀', 'Foguete', Color(0xFFFF6D00)),
    MemoryEmojiItem('💎', 'Diamante', Color(0xFF2979FF)),
    MemoryEmojiItem('⭐', 'Estrela', Color(0xFFFFC107)),
    MemoryEmojiItem('🎯', 'Alvo', Color(0xFFFF334B)),
    MemoryEmojiItem('🔥', 'Fogo', Color(0xFFFF3D00)),
    MemoryEmojiItem('💡', 'Lâmpada', Color(0xFF00E676)),
    MemoryEmojiItem('🧩', 'Puzzle', Color(0xFFB026FF)),
    MemoryEmojiItem('🏆', 'Troféu', Color(0xFFFFD700)),
    MemoryEmojiItem('👑', 'Coroa', Color(0xFFFFAB00)),
    MemoryEmojiItem('🦄', 'Unicórnio', Color(0xFFE040FB)),
    MemoryEmojiItem('🪐', 'Saturno', Color(0xFF7C4DFF)),
    MemoryEmojiItem('🍕', 'Pizza', Color(0xFFFF9100)),
    MemoryEmojiItem('🐱', 'Gato', Color(0xFFFFB74D)),
    MemoryEmojiItem('🥑', 'Abacate', Color(0xFF76FF03)),
  ];

  /// Escalonamento por fileiras:
  /// - 1ª rodada: 3 fileiras (12 cartas = 6 pares)
  /// - 2ª rodada: 4 fileiras (16 cartas = 8 pares)
  /// - 3ª rodada+: 5 fileiras (20 cartas = 10 pares)
  static int getRowsForRound(int round, {int level = 1}) {
    if (round <= 1 && level <= 3) return 3;
    if (round <= 2 && level <= 6) return 4;
    return 5;
  }

  static int getTotalPairsForRows(int rows, {int cols = 4}) {
    return (rows * cols) ~/ 2;
  }

  static List<MemoryCardItem> generateCards({
    required int rows,
    int cols = 4,
    int? seed,
    bool startFaceUp = true,
  }) {
    final pairCount = getTotalPairsForRows(rows, cols: cols);
    final activeEmojis = emojiPool.take(pairCount).toList();

    final list = <MemoryCardItem>[];
    int cardId = 0;

    for (final item in activeEmojis) {
      list.add(
        MemoryCardItem(
          id: cardId++,
          emoji: item.emoji,
          label: item.label,
          accentColor: item.glowColor,
          isFaceUp: startFaceUp,
        ),
      );
      list.add(
        MemoryCardItem(
          id: cardId++,
          emoji: item.emoji,
          label: item.label,
          accentColor: item.glowColor,
          isFaceUp: startFaceUp,
        ),
      );
    }

    if (seed != null) {
      list.shuffle(Random(seed));
    } else {
      list.shuffle();
    }
    return list;
  }
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
  static const int _previewTotalSeconds = 5;

  late int _targetRows;
  late int _totalPairs;
  late List<MemoryCardItem> _cards;

  bool _isPreviewing = true;
  int _previewSecondsLeft = _previewTotalSeconds;
  Timer? _previewTimer;

  int? _firstFlippedIndex;
  bool _isProcessingMatch = false;
  int _pairsFound = 0;

  bool get _isTutorial => widget.currentRound == 1;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    super.dispose();
  }

  void _startRound() {
    _previewTimer?.cancel();
    _firstFlippedIndex = null;
    _isProcessingMatch = false;
    _pairsFound = 0;
    _isPreviewing = true;
    _previewSecondsLeft = _previewTotalSeconds;

    _targetRows = VisualMemoryEngine.getRowsForRound(
      widget.currentRound,
      level: widget.phaseLevel,
    );
    _totalPairs = VisualMemoryEngine.getTotalPairsForRows(_targetRows, cols: 4);

    _cards = VisualMemoryEngine.generateCards(
      rows: _targetRows,
      cols: 4,
      startFaceUp: true,
    );

    _startPreviewTimer();
  }

  void _startPreviewTimer() {
    _previewTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_previewSecondsLeft > 1) {
          _previewSecondsLeft--;
        } else {
          _endPreview();
        }
      });
    });
  }

  void _endPreview() {
    _previewTimer?.cancel();
    _previewTimer = null;
    setState(() {
      _isPreviewing = false;
      for (final card in _cards) {
        if (!card.isMatched) {
          card.isFaceUp = false;
        }
      }
    });
  }

  void _onCardTap(int index) {
    if (_isPreviewing || _isProcessingMatch) return;
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

      if (firstCard.emoji == card.emoji) {
        firstCard.isMatched = true;
        card.isMatched = true;
        _firstFlippedIndex = null;
        _pairsFound++;

        if (_pairsFound == _totalPairs) {
          Future.delayed(const Duration(milliseconds: 550), () {
            if (mounted) {
              widget.onRoundComplete();
            }
          });
        }
      } else {
        _isProcessingMatch = true;
        Future.delayed(const Duration(milliseconds: 750), () {
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
    final previewProgress = _previewSecondsLeft / _previewTotalSeconds;

    return Column(
      children: [
        if (_isTutorial && !_isPreviewing)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                    'Toque nas cartas para encontrar os pares de emojis idênticos.',
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

        // Barra de memorização prévia
        if (_isPreviewing)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardDeepSlate,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.gold.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.remove_red_eye_rounded, color: AppTheme.gold, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'MEMORIZE OS EMOJIS (${_previewSecondsLeft}s)',
                          style: GoogleFonts.orbitron(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            color: AppTheme.gold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _endPreview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNeuroCyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.flash_on_rounded, size: 14),
                      label: Text(
                        'COMEÇAR',
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: previewProgress,
                    minHeight: 5,
                    backgroundColor: AppTheme.surfaceElevated,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
                  ),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'MEMÓRIA VISUAL: $_pairsFound / $_totalPairs PARES ($_targetRows FILEIRAS)',
              style: GoogleFonts.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.3,
                color: AppTheme.primaryNeuroCyan,
              ),
            ),
          ),

        const SizedBox(height: 6),

        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: _targetRows == 3 ? 0.95 : (_targetRows == 4 ? 0.92 : 0.88),
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return _FlipCardWidget(
                    key: ValueKey('card_${card.id}'),
                    isFaceUp: card.isFaceUp || card.isMatched,
                    onTap: () => _onCardTap(index),
                    front: _buildCardFront(card),
                    back: _buildCardBack(),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardFront(MemoryCardItem card) {
    return Container(
      decoration: BoxDecoration(
        color: card.isMatched
            ? card.accentColor.withValues(alpha: 0.22)
            : AppTheme.cardDeepSlate,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: card.accentColor,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: card.accentColor.withValues(alpha: 0.35),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              card.emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 2),
            Text(
              card.label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: card.isMatched ? card.accentColor : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.surfaceBorder,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_alt_rounded,
              size: 26,
              color: AppTheme.primaryNeuroCyan.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 4),
            Container(
              width: 18,
              height: 2,
              decoration: BoxDecoration(
                color: AppTheme.primaryNeuroCyan.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlipCardWidget extends StatefulWidget {
  final bool isFaceUp;
  final Widget front;
  final Widget back;
  final VoidCallback onTap;

  const _FlipCardWidget({
    super.key,
    required this.isFaceUp,
    required this.front,
    required this.back,
    required this.onTap,
  });

  @override
  State<_FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<_FlipCardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: widget.isFaceUp ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(covariant _FlipCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFaceUp != oldWidget.isFaceUp) {
      if (widget.isFaceUp) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final angle = _animation.value * pi;
          final isFaceShowing = angle > (pi / 2);

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0018)
              ..rotateY(angle),
            child: isFaceShowing
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: widget.front,
                  )
                : widget.back,
          );
        },
      ),
    );
  }
}
