import 'package:flutter_test/flutter_test.dart';
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

    test('WordSearchEngine gera grade 8x8 preenchida com palavras alvo', () {
      final result = WordSearchEngine.generateGrid(1);
      final grid = result['grid'] as List<List<String>>;
      final words = result['words'] as List<String>;

      expect(grid.length, 8);
      expect(grid[0].length, 8);
      expect(words.isNotEmpty, true);
    });
  });
}
