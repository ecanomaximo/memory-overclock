enum ChallengeType {
  stroopReflex,
  flashMatrix,
  digitSequence,
}

class ChallengeRoundConfig {
  final int roundNumber;
  final int totalRounds;
  final bool isTutorial;
  final String tutorialInstruction;
  final Map<String, dynamic> params;

  const ChallengeRoundConfig({
    required this.roundNumber,
    required this.totalRounds,
    required this.isTutorial,
    required this.tutorialInstruction,
    this.params = const {},
  });
}

class WaveChallenge {
  final ChallengeType type;
  final String title;
  final String description;
  final int totalRounds;
  final String cognitiveDomain;

  const WaveChallenge({
    required this.type,
    required this.title,
    required this.description,
    required this.totalRounds,
    required this.cognitiveDomain,
  });

  static List<WaveChallenge> createPhaseSession({int level = 1}) {
    // Range de 3 a 7 rodadas calibrado por tipo de jogo e nível
    final int stroopRounds = (level <= 3) ? 4 : 5;
    final int matrixRounds = (level <= 2) ? 4 : (level <= 6 ? 5 : 6);
    final int digitRounds = (level <= 4) ? 4 : 5;

    return [
      WaveChallenge(
        type: ChallengeType.stroopReflex,
        title: 'Seleção de Cores (Stroop)',
        description: 'Bateria de reflexo: valide se a cor da tinta confere com a palavra.',
        totalRounds: stroopRounds,
        cognitiveDomain: 'Controle Inibitório & Reflexo',
      ),
      WaveChallenge(
        type: ChallengeType.flashMatrix,
        title: 'Flash Matrix',
        description: 'Bateria espacial: memorize as células ativadas no grid.',
        totalRounds: matrixRounds,
        cognitiveDomain: 'Memória de Trabalho Espacial',
      ),
      WaveChallenge(
        type: ChallengeType.digitSequence,
        title: 'Memória Numérica (Digit Span)',
        description: 'Bateria sequencial: reproduza a ordem dos dígitos memorizados.',
        totalRounds: digitRounds,
        cognitiveDomain: 'Memória Sequencial de Curto Prazo',
      ),
    ];
  }
}
