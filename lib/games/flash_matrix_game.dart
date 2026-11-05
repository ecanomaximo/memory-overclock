import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

enum GameState { ready, memorizing, guessing, success, failed }

class FlashMatrixGame extends StatefulWidget {
  final int level;
  final ProgressService progressService;

  const FlashMatrixGame({
    super.key,
    required this.level,
    required this.progressService,
  });

  @override
  State<FlashMatrixGame> createState() => _FlashMatrixGameState();
}

class _FlashMatrixGameState extends State<FlashMatrixGame> {
  late int _gridDimension; // Ex: 3 para 3x3, 4 para 4x4
  late int _targetTileCount;
  late int _memorizeDurationMs;

  final Set<int> _targetTiles = {};
  final Set<int> _selectedTiles = {};
  int? _lastWrongTile;

  GameState _state = GameState.ready;
  Timer? _memorizeTimer;
  double _timerProgress = 1.0;
  Timer? _countdownTicker;

  @override
  void initState() {
    super.initState();
    _setupDifficulty();
    _startRound();
  }

  void _setupDifficulty() {
    final lvl = widget.level;
    if (lvl <= 2) {
      _gridDimension = 3; // 3x3 = 9 blocos
      _targetTileCount = 3 + (lvl - 1);
      _memorizeDurationMs = 1800;
    } else if (lvl <= 5) {
      _gridDimension = 4; // 4x4 = 16 blocos
      _targetTileCount = 4 + (lvl - 3);
      _memorizeDurationMs = 1400;
    } else if (lvl <= 8) {
      _gridDimension = 4;
      _targetTileCount = 6 + (lvl - 6);
      _memorizeDurationMs = 1000;
    } else {
      _gridDimension = 5; // 5x5 = 25 blocos
      _targetTileCount = 7 + min(lvl - 9, 4);
      _memorizeDurationMs = 800;
    }
  }

  void _startRound() {
    _targetTiles.clear();
    _selectedTiles.clear();
    _lastWrongTile = null;

    final totalTiles = _gridDimension * _gridDimension;
    final random = Random();

    while (_targetTiles.length < _targetTileCount) {
      _targetTiles.add(random.nextInt(totalTiles));
    }

    setState(() {
      _state = GameState.memorizing;
      _timerProgress = 1.0;
    });

    const stepMs = 50;
    final totalSteps = _memorizeDurationMs / stepMs;
    int currentStep = 0;

    _countdownTicker?.cancel();
    _countdownTicker = Timer.periodic(const Duration(milliseconds: stepMs), (timer) {
      currentStep++;
      if (mounted) {
        setState(() {
          _timerProgress = max(0.0, 1.0 - (currentStep / totalSteps));
        });
      }
    });

    _memorizeTimer?.cancel();
    _memorizeTimer = Timer(Duration(milliseconds: _memorizeDurationMs), () {
      _countdownTicker?.cancel();
      if (mounted) {
        setState(() {
          _state = GameState.guessing;
        });
      }
    });
  }

  void _onTileTap(int index) {
    if (_state != GameState.guessing || _selectedTiles.contains(index)) return;

    if (_targetTiles.contains(index)) {
      setState(() {
        _selectedTiles.add(index);
      });

      // Se encontrou todos os corretos
      if (_selectedTiles.length == _targetTiles.length) {
        _handleSuccess();
      }
    } else {
      // Errou o bloco
      setState(() {
        _lastWrongTile = index;
        _state = GameState.failed;
      });
      _handleFailure();
    }
  }

  void _handleSuccess() {
    setState(() {
      _state = GameState.success;
    });

    final earnedXp = 40 + (widget.level * 10);
    widget.progressService.recordGameCompleted(
      levelCompleted: widget.level,
      earnedXp: earnedXp,
    );
  }

  void _handleFailure() {
    // Dá opção de tentar novamente
  }

  @override
  void dispose() {
    _memorizeTimer?.cancel();
    _countdownTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fase ${widget.level} • ${_gridDimension}x$_gridDimension',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              if (_state == GameState.memorizing) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _timerProgress,
                    minHeight: 8,
                    backgroundColor: AppTheme.surfaceElevated,
                    color: AppTheme.neonCyan,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: _buildGrid(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String message = '';
    Color statusColor = AppTheme.neonCyan;

    switch (_state) {
      case GameState.ready:
      case GameState.memorizing:
        message = 'Memorize os blocos iluminados!';
        statusColor = AppTheme.neonCyan;
        break;
      case GameState.guessing:
        message = 'Toque nos blocos certos: ${_selectedTiles.length} / ${_targetTiles.length}';
        statusColor = Colors.white;
        break;
      case GameState.success:
        message = 'Excelente! Memória Perfeita 🔥';
        statusColor = AppTheme.neonGreen;
        break;
      case GameState.failed:
        message = 'Ops! Bloco incorreto.';
        statusColor = AppTheme.neonPink;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _state == GameState.success
                ? Icons.check_circle
                : _state == GameState.failed
                    ? Icons.error
                    : Icons.remove_red_eye,
            color: statusColor,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final total = _gridDimension * _gridDimension;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridDimension,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: total,
      itemBuilder: (context, index) {
        final isTarget = _targetTiles.contains(index);
        final isSelected = _selectedTiles.contains(index);
        final isWrong = _lastWrongTile == index;

        Color tileColor = AppTheme.surfaceElevated;
        BoxBorder? border;

        if (_state == GameState.memorizing && isTarget) {
          tileColor = AppTheme.neonCyan;
        } else if (isSelected) {
          tileColor = AppTheme.neonGreen;
        } else if (isWrong) {
          tileColor = AppTheme.neonPink;
        } else if (_state == GameState.failed && isTarget) {
          // Revela os que o jogador deveria ter clicado
          tileColor = AppTheme.neonCyan.withOpacity(0.3);
          border = Border.all(color: AppTheme.neonCyan, width: 2);
        }

        return GestureDetector(
          onTap: () => _onTileTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(12),
              border: border,
              boxShadow: (tileColor == AppTheme.neonCyan || tileColor == AppTheme.neonGreen)
                  ? [
                      BoxShadow(
                        color: tileColor.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.black, size: 28)
                  : isWrong
                      ? const Icon(Icons.close, color: Colors.white, size: 28)
                      : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomControls() {
    if (_state == GameState.success) {
      final earnedXp = 40 + (widget.level * 10);
      return Column(
        children: [
          Text(
            '+$earnedXp XP Ganho na Liga!',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.gold,
            ),
          ),
          const SizedBox(height: 12),
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

    if (_state == GameState.failed) {
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
