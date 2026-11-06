import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_overclock/models/onboarding_survey.dart';
import 'package:memory_overclock/services/survey_analytics_service.dart';

void main() {
  group('SurveyAnalyticsService Tests', () {
    test('Calcula porcentagens corretamente para amostra conhecida', () {
      final dataset = [
        OnboardingSurveyData(
          primaryGoal: 'anxiety_relief',
          dominantSymptom: 'racing_thoughts',
          stressFrequency: 'daily',
          dailyCommitmentMinutes: 10,
          completedAt: DateTime.now(),
        ),
        OnboardingSurveyData(
          primaryGoal: 'anxiety_relief',
          dominantSymptom: 'brain_fog',
          stressFrequency: 'daily',
          dailyCommitmentMinutes: 10,
          completedAt: DateTime.now(),
        ),
        OnboardingSurveyData(
          primaryGoal: 'focus_productivity',
          dominantSymptom: 'digital_distraction',
          stressFrequency: 'sometimes',
          dailyCommitmentMinutes: 5,
          completedAt: DateTime.now(),
        ),
        OnboardingSurveyData(
          primaryGoal: 'focus_productivity',
          dominantSymptom: 'digital_distraction',
          stressFrequency: 'sometimes',
          dailyCommitmentMinutes: 15,
          completedAt: DateTime.now(),
        ),
      ];

      final report = SurveyAnalyticsService.generateReport(dataset);

      expect(report.totalCount, 4);
      // 2 de 4 = 50.0%
      expect(report.goalPercentages['Alívio de Ansiedade & Estresse'], 50.0);
      expect(report.goalPercentages['Foco & Produtividade no Trabalho'], 50.0);

      // Frequência de estresse: 2 daily (50%), 2 sometimes (50%)
      expect(report.stressFrequencyPercentages['Quase todos os dias'], 50.0);
      expect(report.stressFrequencyPercentages['Às vezes (1-2x por semana)'], 50.0);
    });

    test('Exportação JSON gera formato válido com sumário e registros brutos', () {
      final dataset = SurveyAnalyticsService.getSampleResearchDataset();
      final jsonString = SurveyAnalyticsService.exportDatasetJson(dataset);

      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      expect(decoded.containsKey('exportedAt'), true);
      expect(decoded.containsKey('summary'), true);
      expect(decoded.containsKey('records'), true);
      expect((decoded['records'] as List).length, dataset.length);
    });
  });
}
