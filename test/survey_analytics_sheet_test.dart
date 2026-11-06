import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memory_overclock/models/onboarding_survey.dart';
import 'package:memory_overclock/models/user_progress.dart';
import 'package:memory_overclock/services/progress_service.dart';
import 'package:memory_overclock/widgets/survey_analytics_sheet.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SurveyAnalyticsSheet renderiza as porcentagens e botão de exportação', (tester) async {
    final survey = OnboardingSurveyData(
      primaryGoal: 'anxiety_relief',
      dominantSymptom: 'racing_thoughts',
      stressFrequency: 'daily',
      dailyCommitmentMinutes: 10,
      completedAt: DateTime.now(),
    );

    final progress = UserProgress(
      lastResetDate: '2026-11-05',
      isLoggedIn: true,
      hasCompletedOnboarding: true,
      surveyData: survey,
    );
    final service = ProgressService(initialProgress: progress);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SurveyAnalyticsSheet(progressService: service),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ESTUDO NEUROCOGNITIVO'), findsOneWidget);
    expect(find.text('EXTRAIR DATASET DO ESTUDO (JSON)'), findsOneWidget);
    expect(find.text('1. Motivação Principal (Por que baixou o app?)'), findsOneWidget);
    expect(find.text('3. Prevalência de Ansiedade e Sobrecarga'), findsOneWidget);
  });
}
