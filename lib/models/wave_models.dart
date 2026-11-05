enum ChallengeType {
  flashMatrix,
  stroopReflex,
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

  static List<WaveChallenge> createDefaultWave({int roundsPerChallenge = 5}) {
    return [
      WaveChallenge(
        type: ChallengeType.flashMatrix,
        title: 'Flash Matrix',
        description: 'Memorize e selecione as células ativadas no grid.',
        totalRounds: roundsPerChallenge,
        cognitiveDomain: 'Memória de Trabalho Espacial',
      ),
      WaveChallenge(
        type: ChallengeType.stroopReflex,
        title: 'Stroop Reflex',
        description: 'Responda rápido se a cor da tinta corresponde à palavra.',
        totalRounds: roundsPerChallenge,
        cognitiveDomain: 'Controle Inibitório',
      ),
      WaveChallenge(
        type: ChallengeType.digitSequence,
        title: 'Digit Memory',
        description: 'Memorize a sequência numérica e reproduza-a com precisão.',
        totalRounds: roundsPerChallenge,
        cognitiveDomain: 'Memória Sequencial',
      ),
    ];
  }
}
