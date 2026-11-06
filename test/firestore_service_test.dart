import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memory_overclock/models/onboarding_survey.dart';
import 'package:memory_overclock/models/user_progress.dart';
import 'package:memory_overclock/services/firestore_service.dart';
import 'package:memory_overclock/services/progress_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FirestoreService Tests', () {
    test('saveSurveyResponse executa com segurança sem erros quando Firebase offline', () async {
      final survey = OnboardingSurveyData(
        primaryGoal: 'anxiety_relief',
        dominantSymptom: 'racing_thoughts',
        stressFrequency: 'daily',
        dailyCommitmentMinutes: 15,
        completedAt: DateTime.now(),
      );

      // Não deve lançar exceção em ambiente de teste
      await expectLater(
        FirestoreService.saveSurveyResponse(
          userId: 'test_uid',
          userName: 'Tester Real',
          userEmail: 'tester@real.com',
          authProvider: 'google',
          surveyData: survey,
        ),
        completes,
      );
    });

    test('ProgressService.completeOnboarding salva localmente e dispara sincronização', () async {
      final progress = UserProgress(lastResetDate: '2026-11-06');
      final service = ProgressService(initialProgress: progress);

      final survey = OnboardingSurveyData(
        primaryGoal: 'focus_productivity',
        dominantSymptom: 'digital_distraction',
        stressFrequency: 'often',
        dailyCommitmentMinutes: 10,
        completedAt: DateTime.now(),
      );

      await service.completeOnboarding(survey);

      expect(service.progress.hasCompletedOnboarding, true);
      expect(service.progress.surveyData, isNotNull);
      expect(service.progress.surveyData!.primaryGoal, 'focus_productivity');
    });
  });
}
