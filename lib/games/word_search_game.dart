import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class WordSearchEngine {
  static const int gridSize = 8;

  static const List<List<String>> roundWordSets = [
    ['FOCO', 'MENTE', 'AGIL'],
    ['MEMORIA', 'NEURONIO', 'SINAPSE'],
    ['CLAREZA', 'REFLEXO', 'CALMA'],
    ['ENERGIA', 'ATENCAO', 'LOGICA'],
  ];

  static Map<String, dynamic> generateGrid(int round) {
    final wordList = roundWordSets[(round - 1) % roundWordSets.length];
    final grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => ''));
    final placedWords = <String>[];
    final rng = Random(round * 42 + 7);

    // Coloca cada palavra no grid (horizontal ou vertical)
    for (final word in wordList) {
      bool placed = false;
      int attempts = 0;

      while (!placed && attempts < 100) {
        attempts++;
        final isHorizontal = rng.nextBool();
        final maxRow = isHorizontal ? gridSize : gridSize - word.length;
        final maxCol = isHorizontal ? gridSize - word.length : gridSize;

        if (maxRow <= 0 || maxCol <= 0) continue;

        final row = rng.nextInt(maxRow);
        final col = rng.nextInt(maxCol);

        bool canPlace = true;
        for (int i = 0; i < word.length; i++) {
          final r = isHorizontal ? row : row + i;
          final c = isHorizontal ? col + i : col;
          if (grid[r][c] != '' && grid[r][c] != word[i]) {
            canPlace = false;
            break;
          }
        }

        if (canPlace) {
          for (int i = 0; i < word.length; i++) {
            final r = isHorizontal ? row : row + i;
            final c = isHorizontal ? col + i : col;
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
  final VoidCallback onRoundComplete;
  final VoidCallback onFailed;

  const WordSearchGame({
    super.key,
    required this.currentRound,
    required this.totalRounds,
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
  final List<Point<int>> _selectedCells = [];
  String _currentSelectedWord = '';

  bool get _isTutorial => widget.currentRound == 1;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  void _startRound() {
    final generated = WordSearchEngine.generateGrid(widget.currentRound);
    _grid = (generated['grid'] as List<List<String>>);
    _targetWords = (generated['words'] as List<String>);
    _foundWords.clear();
    _selectedCells.clear();
    _currentSelectedWord = '';
  }

  void _onCellTap(int row, int col) {
    final point = Point(row, col);

    setState(() {
      if (_selectedCells.contains(point)) {
        // Se tocou na última célula, remove ela
        if (_selectedCells.isNotEmpty && _selectedCells.last == point) {
          _selectedCells.removeLast();
        } else {
          _selectedCells.clear();
        }
      } else {
        _selectedCells.add(point);
      }

      _currentSelectedWord = _selectedCells.map((p) => _grid[p.x][p.y]).join();

      // Checa se formou alguma das palavras alvo
      if (_targetWords.contains(_currentSelectedWord) && !_foundWords.contains(_currentSelectedWord)) {
        _foundWords.add(_currentSelectedWord);
        _selectedCells.clear();
        _currentSelectedWord = '';

        if (_foundWords.length == _targetWords.length) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              widget.onRoundComplete();
            }
          });
        }
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedCells.clear();
      _currentSelectedWord = '';
    });
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
                    'RODADA 1 (TUTORIAL): Toque nas letras em sequência para encontrar as palavras cognitivas.',
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

        const SizedBox(height: 10),

        // Palavra sendo formada
        if (_currentSelectedWord.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SELEÇÃO: $_currentSelectedWord',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: AppTheme.primaryNeuroCyan,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Limpar Seleção',
                icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.alertPink),
                onPressed: _clearSelection,
              ),
            ],
          )
        else
          Text(
            'Encontre: ${_targetWords.length - _foundWords.length} restante(s)',
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
          ),

        const SizedBox(height: 8),

        // Grid 8x8 de Letras
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380, maxHeight: 380),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDeepSlate,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: WordSearchEngine.gridSize,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: WordSearchEngine.gridSize * WordSearchEngine.gridSize,
                    itemBuilder: (context, index) {
                      final r = index ~/ WordSearchEngine.gridSize;
                      final c = index % WordSearchEngine.gridSize;
                      final isSelected = _selectedCells.contains(Point(r, c));

                      return GestureDetector(
                        onTap: () => _onCellTap(r, c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryNeuroCyan.withValues(alpha: 0.3)
                                : AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryNeuroCyan : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _grid[r][c],
                            style: GoogleFonts.orbitron(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? AppTheme.primaryNeuroCyan : Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
