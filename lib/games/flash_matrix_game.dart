import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

enum GameState { ready, memorizing, guessing, success, failed }

class FlashMatrixConfig {
  final int dimension;
  final int targetCount;
  final int durationMs;

  const FlashMatrixConfig({
    required this.dimension,
    required this.targetCount,
    required this.durationMs,
  });

  static FlashMatrixConfig forLevel(int level) {
    if (level <= 2) {
      return FlashMatrixConfig(
        dimension: 3,
        targetCount: 3 + (level - 1),
        durationMs: 1800,
      );
    } else if (level <= 5) {
      return FlashMatrixConfig(
        dimension: 4,
        targetCount: 4 + (level - 3),
        durationMs: 1400,
      );
    } else if (level <= 8) {
      return FlashMatrixConfig(
        dimension: 4,
        targetCount: 6 + (level - 6),
        durationMs: 1000,
      );
    } else {
      return FlashMatrixConfig(
        dimension: 5,
        targetCount: min(12, 7 + (level - 9)),
        durationMs: 800,
      );
    }
  }

  static int calculateXp(int level, {bool isVip = false}) {
    final base = 40 + (level * 10);
    return isVip ? (base * 1.5).round() : base;
  }
}

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
  late FlashMatrixConfig _config;
  final Set<int> _targetTiles = {};
  final Set<int> _selectedTiles = {};
  int? _lastWrongTile;

  GameState _state = GameState.ready;
  Timer? _memorizeTimer;
  Timer? _countdownTicker;
  double _timerProgress = 1.0;

  @override
  void initState() {
    super.initState();
    _config = FlashMatrixConfig.forLevel(widget.level);
    _startRound();
  }

  void _startRound() {
    _targetTiles.clear();
    _selectedTiles.clear();
    _lastWrongTile = null;

    final totalTiles = _config.dimension * _config.dimension;
    final random = Random();

    while (_targetTiles.length < _config.targetCount) {
      _targetTiles.add(random.nextInt(totalTiles));
    }

    setState(() {
      _state = GameState.memorizing;
      _timerProgress = 1.0;
    });

    const stepMs = 50;
    final totalSteps = _config.durationMs / stepMs;
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
    _memorizeTimer = Timer(Duration(milliseconds: _config.durationMs), () {
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

      if (_selectedTiles.length == _targetTiles.length) {
        _handleSuccess();
      }
    } else {
      setState(() {
        _lastWrongTile = index;
        _state = GameState.failed;
      });
    }
  }

  void _handleSuccess() {
    setState(() {
      _state = GameState.success;
    });

    final earnedXp = FlashMatrixConfig.calculateXp(
      widget.level,
      isVip: widget.progressService.progress.isVip,
    );

    widget.progressService.recordGameCompleted(
      levelCompleted: widget.level,
      earnedXp: earnedXp,
    );
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
          'FASE ${widget.level}',
          style: GoogleFonts.orbitron(letterSpacing: 2.0),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              _buildTopStats(),
              const SizedBox(height: 16),
              _buildProgressBar(),
              const SizedBox(height: 16),
              _buildStatusCard(),
              const SizedBox(height: 24),
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

  Widget _buildTopStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.flash_on, color: AppTheme.neonCyan, size: 20),
            const SizedBox(width: 6),
            Text(
              'Grade ${_config.dimension}x${_config.dimension}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppTheme.neonGreen, size: 20),
            const SizedBox(width: 6),
            Text(
              '${_selectedTiles.length} / ${_config.targetCount} Alvos',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: _state == GameState.memorizing ? _timerProgress : 0.0,
        backgroundColor: AppTheme.surfaceElevated,
        valueColor: AlwaysStoppedAnimation<Color>(
          _timerProgress > 0.3 ? AppTheme.neonCyan : AppTheme.neonPink,
        ),
        minHeight: 6,
      ),
    );
  }

  Widget _buildStatusCard() {
    String message;
    Color statusColor;

    switch (_state) {
      case GameState.ready:
      case GameState.memorizing:
        message = 'Memorize os blocos iluminados!';
        statusColor = AppTheme.neonCyan;
        break;
      case GameState.guessing:
        message = 'Toque nos blocos memorizados!';
        statusColor = Colors.white;
        break;
      case GameState.success:
        message = 'Excelente! Memória Perfeita 🔥';
        statusColor = AppTheme.neonGreen;
        break;
      case GameState.failed:
        message = 'Bloco incorreto! Tente de novo.';
        statusColor = AppTheme.neonPink;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
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
                fontSize: 15,
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
    final total = _config.dimension * _config.dimension;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _config.dimension,
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
          tileColor = AppTheme.neonCyan.withValues(alpha: 0.3);
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
                        color: tileColor.withValues(alpha: 0.5),
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
      final earnedXp = FlashMatrixConfig.calculateXp(
        widget.level,
        isVip: widget.progressService.progress.isVip,
      );

      return Column(
        children: [
          Text(
            '+$earnedXp XP Acumulado!',
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.gold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonGreen,
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('AVANÇAR NA TRILHA'),
            ),
          ),
        ],
      );
    }

    if (_state == GameState.failed) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.surfaceElevated,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.refresh),
          label: const Text('TENTAR NOVAMENTE'),
          onPressed: _startRound,
        ),
      );
    }

    return const SizedBox(height: 50);
  }
}


class FlashMatrixWaveChallenge extends StatefulWidget {
  final int currentRound;
  final int totalRounds;
  final VoidCallback onRoundComplete;
  final VoidCallback onFailed;

  const FlashMatrixWaveChallenge({
    super.key,
    required this.currentRound,
    required this.totalRounds,
    required this.onRoundComplete,
    required this.onFailed,
  });

  @override
  State<FlashMatrixWaveChallenge> createState() => _FlashMatrixWaveChallengeState();
}

class _FlashMatrixWaveChallengeState extends State<FlashMatrixWaveChallenge> {
  late FlashMatrixConfig _config;
  final Set<int> _targetTiles = {};
  final Set<int> _selectedTiles = {};
  int? _lastWrongTile;

  GameState _state = GameState.ready;
  Timer? _memorizeTimer;
  Timer? _countdownTicker;
  double _timerProgress = 1.0;

  bool get _isTutorial => widget.currentRound == 1;

  @override
  void initState() {
    super.initState();
    _setupRound();
  }

  void _setupRound() {
    _config = _configForWave(widget.currentRound, widget.totalRounds);
    _startRound();
  }

  FlashMatrixConfig _configForWave(int round, int totalRounds) {
    if (round <= 1) {
      return const FlashMatrixConfig(dimension: 3, targetCount: 3, durationMs: 2200);
    } else if (round == 2) {
      return const FlashMatrixConfig(dimension: 3, targetCount: 4, durationMs: 1800);
    } else if (round == 3) {
      return const FlashMatrixConfig(dimension: 4, targetCount: 4, durationMs: 1500);
    } else if (round == 4) {
      return const FlashMatrixConfig(dimension: 4, targetCount: 5, durationMs: 1300);
    } else if (round == 5) {
      return const FlashMatrixConfig(dimension: 4, targetCount: 6, durationMs: 1100);
    } else {
      return const FlashMatrixConfig(dimension: 5, targetCount: 7, durationMs: 900);
    }
  }

  void _startRound() {
    _targetTiles.clear();
    _selectedTiles.clear();
    _lastWrongTile = null;

    final totalTiles = _config.dimension * _config.dimension;
    final random = Random();

    while (_targetTiles.length < _config.targetCount) {
      _targetTiles.add(random.nextInt(totalTiles));
    }

    setState(() {
      _state = GameState.memorizing;
      _timerProgress = 1.0;
    });

    const stepMs = 50;
    final totalSteps = _config.durationMs / stepMs;
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
    _memorizeTimer = Timer(Duration(milliseconds: _config.durationMs), () {
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

      if (_selectedTiles.length == _targetTiles.length) {
        widget.onRoundComplete();
      }
    } else {
      setState(() {
        _lastWrongTile = index;
        _state = GameState.failed;
      });
      widget.onFailed();
    }
  }

  @override
  void dispose() {
    _memorizeTimer?.cancel();
    _countdownTicker?.cancel();
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
                    'RODADA 1 (TUTORIAL): Memorize as células iluminadas em ciano e toque nelas quando apagarem.',
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
            value: _state == GameState.memorizing ? _timerProgress : 1.0,
            backgroundColor: AppTheme.cardDeepSlate,
            valueColor: AlwaysStoppedAnimation<Color>(
              _state == GameState.memorizing
                  ? AppTheme.accentSolarAmber
                  : AppTheme.accentBioGreen,
            ),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _state == GameState.memorizing
              ? 'MEMORIZE AS POSIÇÕES'
              : 'SELECIONE AS CÉLULAS (${_selectedTiles.length}/${_targetTiles.length})',
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: _state == GameState.memorizing
                ? AppTheme.accentSolarAmber
                : AppTheme.primaryNeuroCyan,
          ),
        ),
        const Spacer(),
        Center(
          child: AspectRatio(
            aspectRatio: 1.0,
            child: _buildGrid(),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _config.dimension * _config.dimension,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _config.dimension,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final isTarget = _targetTiles.contains(index);
        final isSelected = _selectedTiles.contains(index);
        final isWrong = _lastWrongTile == index;

        Color tileColor = AppTheme.cardDeepSlate;
        Border? border = Border.all(color: AppTheme.cardBorderMuted, width: 1.5);
        List<BoxShadow> shadows = [];

        if (_state == GameState.memorizing && isTarget) {
          tileColor = AppTheme.primaryNeuroCyan;
          border = Border.all(color: AppTheme.primaryNeuroCyan, width: 2);
          shadows = [
            BoxShadow(
              color: AppTheme.primaryNeuroCyan.withValues(alpha: 0.5),
              blurRadius: 14,
            ),
          ];
        } else if (isSelected) {
          tileColor = AppTheme.accentBioGreen;
          border = Border.all(color: AppTheme.accentBioGreen, width: 2);
          shadows = [
            BoxShadow(
              color: AppTheme.accentBioGreen.withValues(alpha: 0.5),
              blurRadius: 12,
            ),
          ];
        } else if (isWrong) {
          tileColor = const Color(0xFFFF4D4D);
          border = Border.all(color: const Color(0xFFFF4D4D), width: 2);
        }

        return GestureDetector(
          onTap: () => _onTileTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(12),
              border: border,
              boxShadow: shadows,
            ),
          ),
        );
      },
    );
  }
}
