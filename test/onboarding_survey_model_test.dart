import 'package:flutter_test/flutter_test.dart';
import 'package:memory_overclock/models/onboarding_survey.dart';
import 'package:memory_overclock/models/user_progress.dart';

void main() {
  group('OnboardingSurveyData Tests', () {
    test('Serialização e deserialização conservam todos os campos', () {
      final now = DateTime(2026, 11, 5, 20, 0);
      final survey = OnboardingSurveyData(
        primaryGoal: 'anxiety_relief',
        dominantSymptom: 'racing_thoughts',
        stressFrequency: 'daily',
        dailyCommitmentMinutes: 10,
        completedAt: now,
      );

      final map = survey.toMap();
      final restored = OnboardingSurveyData.fromMap(map);

      expect(restored.primaryGoal, 'anxiety_relief');
      expect(restored.dominantSymptom, 'racing_thoughts');
      expect(restored.stressFrequency, 'daily');
      expect(restored.dailyCommitmentMinutes, 10);
      expect(restored.completedAt, now);
      expect(restored.profileTitle, 'Alívio de Ansiedade & Clareza Mental');
      expect(restored.recommendedFocusDomain, 'Controle Inibitório & Respiração');
    });

    test('UserProgress integra surveyData e hasCompletedOnboarding com retrocompatibilidade', () {
      final progressNew = UserProgress(lastResetDate: '2026-11-05');
      expect(progressNew.hasCompletedOnboarding, false);
      expect(progressNew.surveyData, isNull);

      final progressOldUser = UserProgress.fromJson({
        'currentLevel': 3,
        'weeklyXp': 120,
        'lastResetDate': '2026-11-05',
      });
      // Usuário antigo que já estava em fases superiores assume onboarding concluído
      expect(progressOldUser.hasCompletedOnboarding, true);
    });
  });
}
