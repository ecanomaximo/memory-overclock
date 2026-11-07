import 'package:flutter_test/flutter_test.dart';
import 'package:memory_overclock/games/color_clash_game.dart';
import 'package:memory_overclock/games/digit_sequence_game.dart';
import 'package:memory_overclock/games/stroop_reflex_game.dart';
import 'package:memory_overclock/games/visual_memory_game.dart';
import 'package:memory_overclock/games/word_search_game.dart';
import 'package:memory_overclock/models/adaptive_difficulty.dart';
import 'package:memory_overclock/models/onboarding_survey.dart';
import 'package:memory_overclock/models/wave_models.dart';

void main() {
  group('Adaptive Difficulty Profile Tests', () {
    test('Perfil padrão quando survey é nulo', () {
      final profile = AdaptiveDifficultyProfile.fromSurvey(null);
      expect(profile.timeMultiplier, 1.0);
      expect(profile.bonusSeconds, 0);
    });

    test('Calibração Anti-Ansiedade concede +35% de tempo e bônus', () {
      final survey = OnboardingSurveyData(
        primaryGoal: 'anxiety_relief',
        dominantSymptom: 'racing_thoughts',
        stressFrequency: 'daily',
        dailyCommitmentMinutes: 10,
        completedAt: DateTime.now(),
      );

      final profile = AdaptiveDifficultyProfile.fromSurvey(survey);
      expect(profile.timeMultiplier, greaterThanOrEqualTo(1.3));
      expect(profile.bonusSeconds, greaterThan(0));
      expect(profile.recommendationNotice, contains('Anti-Ansiedade'));
    });

    test('Sessão prioriza jogos de memória quando sintoma é esquecimento', () {
      final survey = OnboardingSurveyData(
        primaryGoal: 'memory_improvement',
        dominantSymptom: 'forgetfulness',
        stressFrequency: 'sometimes',
        dailyCommitmentMinutes: 15,
        completedAt: DateTime.now(),
      );

      final profile = AdaptiveDifficultyProfile.fromSurvey(survey);
      final challenges = WaveChallenge.createPhaseSession(level: 1, adaptiveProfile: profile);

      expect(challenges.length, 3);
      expect(challenges.any((c) => c.type == ChallengeType.visualMemory), true);
      expect(challenges.any((c) => c.type == ChallengeType.flashMatrix), true);
    });

    test('WordSearchEngine escala quantidade de palavras conforme o nível', () {
      final easyWords = WordSearchEngine.getWordListForRound(1, level: 2);
      expect(easyWords.length, 2);

      final mediumWords = WordSearchEngine.getWordListForRound(1, level: 5);
      expect(mediumWords.length, 3);

      final hardWords = WordSearchEngine.getWordListForRound(1, level: 8);
      expect(hardWords.length, 4);

      final result = WordSearchEngine.generateGrid(1, level: 2);
      final grid = result['grid'] as List<List<String>>;
      final words = result['words'] as List<String>;

      expect(grid.length, 8);
      expect(grid[0].length, 8);
      expect(words.length, 2);
    });

    test('StroopEngine escala paleta de cores conforme a fase', () {
      final pEasy = StroopEngine.getPaletteForLevel(2);
      expect(pEasy.length, 4);

      final pMed = StroopEngine.getPaletteForLevel(5);
      expect(pMed.length, 6);

      final pHard = StroopEngine.getPaletteForLevel(8);
      expect(pHard.length, 9);
    });

    test('ColorClashGame escala paleta de cores conforme o nível', () {
      final cEasy = ColorClashGame.getColorsForLevel(2);
      expect(cEasy.length, 4);

      final cMed = ColorClashGame.getColorsForLevel(5);
      expect(cMed.length, 6);

      final cHard = ColorClashGame.getColorsForLevel(8);
      expect(cHard.length, 8);
    });

    test('DigitSequenceEngine escala tamanho da sequência e velocidade por nível', () {
      final lenEasy = DigitSequenceEngine.getSequenceLengthForRound(1, 5, level: 1);
      final lenHard = DigitSequenceEngine.getSequenceLengthForRound(1, 5, level: 8);
      expect(lenEasy, 3);
      expect(lenHard, 5);

      final durationEasy = DigitSequenceEngine.getDisplayDurationMs(1, level: 1);
      final durationHard = DigitSequenceEngine.getDisplayDurationMs(1, level: 8);
      expect(durationHard, lessThan(durationEasy));
    });

    test('VisualMemoryEngine escala fileiras (3, 4, 5) e gera pares com emojis', () {
      final r1 = VisualMemoryEngine.getRowsForRound(1, level: 1);
      final r2 = VisualMemoryEngine.getRowsForRound(2, level: 4);
      final r3 = VisualMemoryEngine.getRowsForRound(3, level: 7);

      expect(r1, 3); // 3 fileiras na primeira
      expect(r2, 4); // 4 fileiras no próximo desafio
      expect(r3, 5); // 5 fileiras no seguinte

      final cards1 = VisualMemoryEngine.generateCards(rows: r1, cols: 4, seed: 100);
      expect(cards1.length, 12); // 3x4 = 12 cartas (6 pares)
      expect(cards1.every((c) => c.isFaceUp), true); // Preview inicial de 5s começa aberto

      final cards3 = VisualMemoryEngine.generateCards(rows: r3, cols: 4, seed: 200);
      expect(cards3.length, 20); // 5x4 = 20 cartas (10 pares)

      // Confere se cada emoji tem exatamente um par idêntico
      final emojiCounts = <String, int>{};
      for (final c in cards3) {
        emojiCounts[c.emoji] = (emojiCounts[c.emoji] ?? 0) + 1;
      }
      expect(emojiCounts.values.every((cnt) => cnt == 2), true);
    });
  });
}
