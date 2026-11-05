import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class ReadingPrompt {
  final String text;
  final String question;
  final List<String> options;
  final int correctOptionIndex;

  const ReadingPrompt({
    required this.text,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });
}

enum ReadingState { reading, answering, correct, incorrect }

class ReadingRecallGame extends StatefulWidget {
  final int level;
  final ProgressService progressService;

  const ReadingRecallGame({
    super.key,
    required this.level,
    required this.progressService,
  });

  @override
  State<ReadingRecallGame> createState() => _ReadingRecallGameState();
}

class _ReadingRecallGameState extends State<ReadingRecallGame> {
  static const List<ReadingPrompt> allPrompts = [
    ReadingPrompt(
      text: 'O agente secreto viajou para Tóquio no voo 408 vestindo um sobretudo cinza.',
      question: 'Para qual cidade o agente secreto viajou?',
      options: ['Londres', 'Tóquio', 'Nova York', 'Paris'],
      correctOptionIndex: 1,
    ),
    ReadingPrompt(
      text: 'A nave decolou às 09:30 levando exatamente 3 astronautas e 5 satélites.',
      question: 'Quantos astronautas estavam a bordo da nave?',
      options: ['2 astronautas', '4 astronautas', '3 astronautas', '5 astronautas'],
      correctOptionIndex: 2,
    ),
    ReadingPrompt(
      text: 'Na floresta escura, o lobo prateado encontrou 7 cristais azuis perto do rio calmo.',
      question: 'Qual era a cor dos 7 cristais encontrados?',
      options: ['Verdes', 'Azuis', 'Vermelhos', 'Dourados'],
      correctOptionIndex: 1,
    ),
    ReadingPrompt(
      text: 'O cientista ativou o gerador quântico na frequência 88 Hz usando a chave vermelha.',
      question: 'Qual era a frequência configurada no gerador?',
      options: ['44 Hz', '60 Hz', '88 Hz', '120 Hz'],
      correctOptionIndex: 2,
    ),
    ReadingPrompt(
      text: 'O submarino amarelo submergiu a 300 metros de profundidade na costa do Oceano Pacífico.',
      question: 'Em qual oceano o submarino submergiu?',
      options: ['Atlântico', 'Índico', 'Ártico', 'Pacífico'],
      correctOptionIndex: 3,
    ),
    ReadingPrompt(
      text: 'A chave dourada estava guardada dentro de um cofre de ferro no 4º andar da torre.',
      question: 'Em qual andar da torre o cofre estava localizado?',
      options: ['1º andar', '2º andar', '4º andar', '5º andar'],
      correctOptionIndex: 2,
    ),
  ];

  late ReadingPrompt _currentPrompt;
  late int _readingDurationMs;

  ReadingState _state = ReadingState.reading;
  double _timeProgress = 1.0;
  Timer? _countdownTicker;
  Timer? _readTimer;
  int? _selectedAnswerIndex;

  @override
  void initState() {
    super.initState();
    _setupDifficulty();
    _startRound();
  }

  void _setupDifficulty() {
    final lvl = widget.level;
    if (lvl <= 3) {
      _readingDurationMs = 4000; // 4 segundos para crianças e iniciantes
    } else if (lvl <= 6) {
      _readingDurationMs = 3000; // 3 segundos
    } else {
      _readingDurationMs = 2200; // 2.2 segundos (leitura rápida)
    }
  }

  void _startRound() {
    final random = Random();
    _currentPrompt = allPrompts[random.nextInt(allPrompts.length)];
    _selectedAnswerIndex = null;
    _timeProgress = 1.0;

    setState(() {
      _state = ReadingState.reading;
    });

    const stepMs = 50;
    final totalSteps = _readingDurationMs / stepMs;
    int currentStep = 0;

    _countdownTicker?.cancel();
    _countdownTicker = Timer.periodic(const Duration(milliseconds: stepMs), (timer) {
      currentStep++;
      if (mounted) {
        setState(() {
          _timeProgress = max(0.0, 1.0 - (currentStep / totalSteps));
        });
      }
    });

    _readTimer?.cancel();
    _readTimer = Timer(Duration(milliseconds: _readingDurationMs), () {
      _countdownTicker?.cancel();
      if (mounted) {
        setState(() {
          _state = ReadingState.answering;
        });
      }
    });
  }

  void _onOptionSelected(int index) {
    if (_state != ReadingState.answering) return;

    setState(() {
      _selectedAnswerIndex = index;
      if (index == _currentPrompt.correctOptionIndex) {
        _state = ReadingState.correct;
      } else {
        _state = ReadingState.incorrect;
      }
    });

    if (_state == ReadingState.correct) {
      final earnedXp = 50 + (widget.level * 10);
      widget.progressService.recordGameCompleted(
        levelCompleted: widget.level,
        earnedXp: earnedXp,
      );
    }
  }

  @override
  void dispose() {
    _countdownTicker?.cancel();
    _readTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fase ${widget.level} • Leitura Relâmpago',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              _buildTopInstruction(),
              const SizedBox(height: 16),
              if (_state == ReadingState.reading) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _timeProgress,
                    minHeight: 8,
                    backgroundColor: AppTheme.surfaceElevated,
                    color: AppTheme.neonCyan,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: Center(
                  child: _buildMainContent(),
                ),
              ),
              const SizedBox(height: 16),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopInstruction() {
    String text = 'LEIA COM ATENÇÃO! O texto vai sumir.';
    Color color = AppTheme.neonCyan;

    if (_state == ReadingState.answering) {
      text = 'Qual era o detalhe? Responda rápido:';
      color = Colors.white;
    } else if (_state == ReadingState.correct) {
      text = 'Excelente! Retenção de leitura impecável 🔥';
      color = AppTheme.neonGreen;
    } else if (_state == ReadingState.incorrect) {
      text = 'Ops! Resposta incorreta.';
      color = AppTheme.neonPink;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, color: color),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_state == ReadingState.reading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neonCyan.withValues(alpha: 0.2),
              blurRadius: 18,
            )
          ],
        ),
        child: Text(
          _currentPrompt.text,
          style: const TextStyle(
            fontSize: 22,
            height: 1.5,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Estado de Perguntas e Respostas
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _currentPrompt.question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.gold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(_currentPrompt.options.length, (index) {
          final option = _currentPrompt.options[index];
          final isSelected = _selectedAnswerIndex == index;
          final isCorrect = index == _currentPrompt.correctOptionIndex;

          Color btnColor = AppTheme.surface;
          Color borderColor = Colors.white12;
          Color textColor = Colors.white;

          if (_state == ReadingState.correct && isSelected) {
            btnColor = AppTheme.neonGreen.withValues(alpha: 0.2);
            borderColor = AppTheme.neonGreen;
            textColor = AppTheme.neonGreen;
          } else if (_state == ReadingState.incorrect) {
            if (isSelected) {
              btnColor = AppTheme.neonPink.withValues(alpha: 0.2);
              borderColor = AppTheme.neonPink;
              textColor = AppTheme.neonPink;
            } else if (isCorrect) {
              borderColor = AppTheme.neonGreen;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: btnColor,
                  side: BorderSide(color: borderColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => _onOptionSelected(index),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomControls() {
    if (_state == ReadingState.correct) {
      final earnedXp = 50 + (widget.level * 10);
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

    if (_state == ReadingState.incorrect) {
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
            'TENTAR OUTRA FRASE',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          onPressed: _startRound,
        ),
      );
    }

    return const SizedBox(height: 52);
  }
}
