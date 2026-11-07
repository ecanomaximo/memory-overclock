import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class WordSearchEngine {
  static const int gridSize = 8;

  static List<String> getWordListForRound(int round, {int level = 1}) {
    if (level <= 3) {
      // Níveis 1 a 3: 2 palavras curtas (3 a 6 letras)
      const easySets = [
        ['FOCO', 'MENTE'],
        ['AGIL', 'CALMA'],
        ['LUZ', 'PENSAR'],
        ['ALVO', 'GUIA'],
      ];
      return easySets[(round - 1) % easySets.length];
    } else if (level <= 6) {
      // Níveis 4 a 6: 3 palavras moderadas (4 a 7 letras)
      const mediumSets = [
        ['MEMORIA', 'SINAPSE', 'FOCO'],
        ['CLAREZA', 'REFLEXO', 'CALMA'],
        ['ENERGIA', 'ATENCAO', 'LOGICA'],
        ['CEREBRO', 'NEURONIO', 'AGIL'],
      ];
      return mediumSets[(round - 1) % mediumSets.length];
    } else {
      // Níveis 7+: 4 palavras desafiadoras (4 a 8 letras)
      const hardSets = [
        ['SINAPSE', 'MEMORIA', 'COGNICAO', 'MENTE'],
        ['NEURONIO', 'REFLEXO', 'CEREBRO', 'AGIL'],
        ['ESTIMULO', 'FOCO', 'LOGICA', 'ATENCAO'],
        ['CONEXAO', 'ENERGIA', 'DECISAO', 'CLAREZA'],
      ];
      return hardSets[(round - 1) % hardSets.length];
    }
  }

  static Map<String, dynamic> generateGrid(int round, {int level = 1}) {
    final wordList = getWordListForRound(round, level: level);
    final grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => ''));
    final placedWords = <String>[];
    final rng = Random(round * 42 + level * 7 + 13);

    // Coloca cada palavra no grid (horizontal, vertical ou diagonal)
    for (final word in wordList) {
      bool placed = false;
      int attempts = 0;

      while (!placed && attempts < 150) {
        attempts++;
        // 0: horizontal, 1: vertical, 2: diagonal
        final direction = rng.nextInt(3);

        int maxRow = gridSize;
        int maxCol = gridSize;
        if (direction == 0) {
          maxCol = gridSize - word.length + 1;
        } else if (direction == 1) {
          maxRow = gridSize - word.length + 1;
        } else {
          maxRow = gridSize - word.length + 1;
          maxCol = gridSize - word.length + 1;
        }

        if (maxRow <= 0 || maxCol <= 0) continue;

        final row = rng.nextInt(maxRow);
        final col = rng.nextInt(maxCol);

        bool canPlace = true;
        for (int i = 0; i < word.length; i++) {
          final r = direction == 0 ? row : row + i;
          final c = direction == 1 ? col : col + i;
          if (grid[r][c] != '' && grid[r][c] != word[i]) {
            canPlace = false;
            break;
          }
        }

        if (canPlace) {
          for (int i = 0; i < word.length; i++) {
            final r = direction == 0 ? row : row + i;
            final c = direction == 1 ? col : col + i;
            grid[r][c] = word[i];
          }
          placed = true;
          placedWords.add(word);
        }
      }
    }

    // Preenche o restante com letras aleatórias
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c] == '') {
          grid[r][c] = alphabet[rng.nextInt(alphabet.length)];
        }
      }
    }

    return {
      'grid': grid,
      'words': placedWords,
    };
  }
}

class WordSearchGame extends StatefulWidget {
  final int currentRound;
  final int totalRounds;
  final int phaseLevel;
  final VoidCallback onRoundComplete;
  final VoidCallback onFailed;

  const WordSearchGame({
    super.key,
    required this.currentRound,
    required this.totalRounds,
    this.phaseLevel = 1,
    required this.onRoundComplete,
    required this.onFailed,
  });

  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  late List<List<String>> _grid;
  late List<String> _targetWords;
  final Set<String> _foundWords = {};
  final Set<Point<int>> _permanentlyFoundCells = {};
  final List<Point<int>> _activeDragCells = [];
  Point<int>? _dragStartPoint;
  String _currentSelectedWord = '';

  bool get _isTutorial => widget.currentRound == 1;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  void _startRound() {
    final generated = WordSearchEngine.generateGrid(
      widget.currentRound,
      level: widget.phaseLevel,
    );
    _grid = (generated['grid'] as List<List<String>>);
    _targetWords = (generated['words'] as List<String>);
    _foundWords.clear();
    _permanentlyFoundCells.clear();
    _activeDragCells.clear();
    _dragStartPoint = null;
    _currentSelectedWord = '';
  }

  Point<int> _clampedPointFromOffset(Offset localPos, double cellSize) {
    final col = (localPos.dx / cellSize).floor().clamp(0, WordSearchEngine.gridSize - 1);
    final row = (localPos.dy / cellSize).floor().clamp(0, WordSearchEngine.gridSize - 1);
    return Point(row, col);
  }

  List<Point<int>> _calculateLine(Point<int> start, Point<int> current) {
    final dr = current.x - start.x;
    final dc = current.y - start.y;

    if (dr == 0 && dc == 0) {
      return [start];
    }

    final absR = dr.abs();
    final absC = dc.abs();

    int stepR = 0;
    int stepC = 0;
    int count = 0;

    // Se é puramente horizontal
    if (absR == 0) {
      stepC = dc > 0 ? 1 : -1;
      count = absC;
    }
    // Se é puramente vertical
    else if (absC == 0) {
      stepR = dr > 0 ? 1 : -1;
      count = absR;
    }
    // Se é diagonal perfeita
    else if (absR == absC) {
      stepR = dr > 0 ? 1 : -1;
      stepC = dc > 0 ? 1 : -1;
      count = absR;
    }
    // Snap inteligente para a direção dominante
    else if (absC > 2 * absR) {
      stepC = dc > 0 ? 1 : -1;
      count = absC;
    } else if (absR > 2 * absC) {
      stepR = dr > 0 ? 1 : -1;
      count = absR;
    } else {
      stepR = dr > 0 ? 1 : -1;
      stepC = dc > 0 ? 1 : -1;
      count = min(absR, absC);
    }

    final line = <Point<int>>[];
    for (int i = 0; i <= count; i++) {
      final r = start.x + i * stepR;
      final c = start.y + i * stepC;
      if (r >= 0 && r < WordSearchEngine.gridSize && c >= 0 && c < WordSearchEngine.gridSize) {
        line.add(Point(r, c));
      }
    }
    return line.isNotEmpty ? line : [start];
  }

  void _onDragStart(Offset localPos, double cellSize) {
    final point = _clampedPointFromOffset(localPos, cellSize);
    setState(() {
      _dragStartPoint = point;
      _activeDragCells.clear();
      _activeDragCells.add(point);
      _currentSelectedWord = _grid[point.x][point.y];
    });
  }

  void _onDragUpdate(Offset localPos, double cellSize) {
    if (_dragStartPoint == null) return;
    final current = _clampedPointFromOffset(localPos, cellSize);
    final line = _calculateLine(_dragStartPoint!, current);

    setState(() {
      _activeDragCells.clear();
      _activeDragCells.addAll(line);
      _currentSelectedWord = _activeDragCells.map((p) => _grid[p.x][p.y]).join();
    });
  }

  void _onDragEnd() {
    if (_activeDragCells.isEmpty) return;

    final word = _currentSelectedWord;
    final reversed = word.split('').reversed.join();

    String? matchedWord;
    if (_targetWords.contains(word) && !_foundWords.contains(word)) {
      matchedWord = word;
    } else if (_targetWords.contains(reversed) && !_foundWords.contains(reversed)) {
      matchedWord = reversed;
    }

    setState(() {
      if (matchedWord != null) {
        _foundWords.add(matchedWord);
        _permanentlyFoundCells.addAll(_activeDragCells);

        if (_foundWords.length == _targetWords.length) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              widget.onRoundComplete();
            }
          });
        }
      }
      _activeDragCells.clear();
      _currentSelectedWord = '';
      _dragStartPoint = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isTutorial)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.cardDeepSlate,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primaryNeuroCyan.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.touch_app_rounded, size: 16, color: AppTheme.primaryNeuroCyan),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'RODADA 1 (TUTORIAL): Arraste o dedo ou mouse sobre as letras para circular as palavras.',
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

        const SizedBox(height: 6),

        // Palavras a encontrar
        Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: _targetWords.map((word) {
            final isFound = _foundWords.contains(word);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isFound
                    ? AppTheme.accentBioGreen.withValues(alpha: 0.2)
                    : AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFound ? AppTheme.accentBioGreen : AppTheme.surfaceBorder,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFound ? Icons.check_circle_rounded : Icons.search_rounded,
                    size: 14,
                    color: isFound ? AppTheme.accentBioGreen : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    word,
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: isFound ? AppTheme.accentBioGreen : AppTheme.textPrimary,
                      decoration: isFound ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 8),

        // Feedback de arrasto ao vivo
        if (_currentSelectedWord.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryNeuroCyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryNeuroCyan.withValues(alpha: 0.5)),
            ),
            child: Text(
              'SELEÇÃO: $_currentSelectedWord',
              style: GoogleFonts.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppTheme.primaryNeuroCyan,
              ),
            ),
          )
        else
          Text(
            'Arraste em linha reta para selecionar (${_targetWords.length - _foundWords.length} restantes)',
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
          ),

        const SizedBox(height: 8),

        // Grid 8x8 com detecção de arrasto clássica
        Expanded(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableSize = min(constraints.maxWidth, constraints.maxHeight);
                final size = min(380.0, availableSize > 200 ? availableSize : 340.0);
                const padding = 6.0;
                final innerSize = size - (padding * 2);
                final cellSize = innerSize / WordSearchEngine.gridSize;

                return Container(
                  width: size,
                  height: size,
                  padding: const EdgeInsets.all(padding),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDeepSlate,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (details) => _onDragStart(details.localPosition, cellSize),
                    onPanUpdate: (details) => _onDragUpdate(details.localPosition, cellSize),
                    onPanEnd: (_) => _onDragEnd(),
                    onPanCancel: () => _onDragEnd(),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: WordSearchEngine.gridSize * WordSearchEngine.gridSize,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: WordSearchEngine.gridSize,
                        mainAxisSpacing: 3,
                        crossAxisSpacing: 3,
                      ),
                      itemBuilder: (context, index) {
                        final r = index ~/ WordSearchEngine.gridSize;
                        final c = index % WordSearchEngine.gridSize;
                        final point = Point(r, c);

                        final isFound = _permanentlyFoundCells.contains(point);
                        final isDragging = _activeDragCells.contains(point);

                        Color bgColor;
                        Color borderColor;
                        Color textColor;
                        double borderWidth = 1.0;

                        if (isFound) {
                          bgColor = AppTheme.accentBioGreen.withValues(alpha: 0.35);
                          borderColor = AppTheme.accentBioGreen;
                          textColor = AppTheme.accentBioGreen;
                          borderWidth = 1.8;
                        } else if (isDragging) {
                          bgColor = AppTheme.primaryNeuroCyan.withValues(alpha: 0.45);
                          borderColor = AppTheme.primaryNeuroCyan;
                          textColor = AppTheme.primaryNeuroCyan;
                          borderWidth = 2.0;
                        } else {
                          bgColor = AppTheme.surfaceElevated;
                          borderColor = Colors.transparent;
                          textColor = Colors.white;
                        }

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor, width: borderWidth),
                            boxShadow: (isFound || isDragging)
                                ? [
                                    BoxShadow(
                                      color: (isFound
                                              ? AppTheme.accentBioGreen
                                              : AppTheme.primaryNeuroCyan)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _grid[r][c],
                            style: GoogleFonts.orbitron(
                              fontSize: 15,
                              fontWeight: (isFound || isDragging)
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
