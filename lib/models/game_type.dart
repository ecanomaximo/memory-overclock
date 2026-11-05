import 'package:flutter/material.dart';

enum GameType {
  matrix,   // Memória Visual / Espacial
  reading,  // Desafio de Leitura & Retenção de Palavras
  colors,   // Desafio de Cores & Efeito Stroop
}

class LevelConfig {
  final int level;
  final GameType type;
  final String title;
  final String description;
  final IconData icon;

  const LevelConfig({
    required this.level,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
  });

  static LevelConfig getConfig(int level) {
    final isBoss = level % 5 == 0;

    if (isBoss) {
      return LevelConfig(
        level: level,
        type: GameType.matrix,
        title: 'PROVA DE FOGO (BOSS)',
        description: 'Desafio extremo de velocidade e precisão!',
        icon: Icons.military_tech,
      );
    }

    // Alterna os tipos de jogos pela trilha
    final cycle = (level - 1) % 3;
    switch (cycle) {
      case 0:
        return LevelConfig(
          level: level,
          type: GameType.matrix,
          title: 'Matriz Espacial',
          description: 'Memorize as posições dos blocos de neon.',
          icon: Icons.grid_view_rounded,
        );
      case 1:
        return LevelConfig(
          level: level,
          type: GameType.colors,
          title: 'Conflito de Cores',
          description: 'Memorize as cores e vença o conflito visual.',
          icon: Icons.palette_rounded,
        );
      case 2:
      default:
        return LevelConfig(
          level: level,
          type: GameType.reading,
          title: 'Leitura Relâmpago',
          description: 'Leia o texto rápido e retenha os detalhes-chave.',
          icon: Icons.menu_book_rounded,
        );
    }
  }
}
