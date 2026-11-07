import 'adaptive_difficulty.dart';

enum ChallengeType {
  stroopReflex,
  flashMatrix,
  digitSequence,
  visualMemory,
  wordSearch,
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

  static List<WaveChallenge> createPhaseSession({
    int level = 1,
    AdaptiveDifficultyProfile? adaptiveProfile,
  }) {
    final int stroopRounds = (level <= 3) ? 3 : 4;
    final int matrixRounds = (level <= 2) ? 3 : 4;
    final int digitRounds = (level <= 4) ? 3 : 4;
    const int memoryRounds = 3;
    const int wordSearchRounds = 2;

    final allChallenges = <WaveChallenge>[
      WaveChallenge(
        type: ChallengeType.stroopReflex,
        title: 'Seleção de Cores (Stroop)',
        description: 'Bateria de reflexo: valide se a cor primária bate com a palavra.',
        totalRounds: stroopRounds,
        cognitiveDomain: 'Controle Inibitório & Reflexo',
      ),
      const WaveChallenge(
        type: ChallengeType.visualMemory,
        title: 'Jogo da Memória Visual',
        description: 'Bateria de reconhecimento: encontre os pares de imagens neurais.',
        totalRounds: memoryRounds,
        cognitiveDomain: 'Memória Visual de Trabalho',
      ),
      WaveChallenge(
        type: ChallengeType.flashMatrix,
        title: 'Flash Matrix',
        description: 'Bateria espacial: memorize as células ativadas no grid.',
        totalRounds: matrixRounds,
        cognitiveDomain: 'Memória de Trabalho Espacial',
      ),
      const WaveChallenge(
        type: ChallengeType.wordSearch,
        title: 'Caça-Palavras Cognitivo',
        description: 'Bateria de escaneamento: localize as palavras-chave na grade.',
        totalRounds: wordSearchRounds,
        cognitiveDomain: 'Atenção Sustentada & Foco',
      ),
      WaveChallenge(
        type: ChallengeType.digitSequence,
        title: 'Memória Numérica (Digit Span)',
        description: 'Bateria sequencial com pulso: reproduza os dígitos na ordem.',
        totalRounds: digitRounds,
        cognitiveDomain: 'Memória Sequencial de Curto Prazo',
      ),
    ];

    // Se o jogador relatou esquecimento, prioriza jogos mnemônicos
    if (adaptiveProfile?.dominantSymptom == 'forgetfulness') {
      return [
        allChallenges[1], // visualMemory
        allChallenges[2], // flashMatrix
        allChallenges[4], // digitSequence
      ];
    }

    // Se o jogador relatou ansiedade ou estresse alto, adota ritmo calmo com Caça-Palavras e Memória
    if (adaptiveProfile?.primaryGoal == 'anxiety_relief' || adaptiveProfile?.stressFrequency == 'daily') {
      return [
        allChallenges[1], // visualMemory
        allChallenges[3], // wordSearch
        allChallenges[0], // stroopReflex
      ];
    }

    // Por fase, rotaciona os 5 jogos para máxima diversidade
    final phaseOffset = (level - 1) % allChallenges.length;
    final selected = <WaveChallenge>[];
    for (int i = 0; i < 3; i++) {
      selected.add(allChallenges[(phaseOffset + i) % allChallenges.length]);
    }
    return selected;
  }
}
