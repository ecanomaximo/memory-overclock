import 'dart:convert';
import '../models/onboarding_survey.dart';

class SurveyAnalyticsReport {
  final int totalCount;
  final Map<String, double> goalPercentages;
  final Map<String, double> symptomPercentages;
  final Map<String, double> stressFrequencyPercentages;
  final Map<String, double> commitmentPercentages;

  const SurveyAnalyticsReport({
    required this.totalCount,
    required this.goalPercentages,
    required this.symptomPercentages,
    required this.stressFrequencyPercentages,
    required this.commitmentPercentages,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalCount': totalCount,
      'goalPercentages': goalPercentages,
      'symptomPercentages': symptomPercentages,
      'stressFrequencyPercentages': stressFrequencyPercentages,
      'commitmentPercentages': commitmentPercentages,
    };
  }

  String toJson() => const JsonEncoder.withIndent('  ').convert(toMap());
}

class SurveyAnalyticsService {
  static const Map<String, String> goalLabels = {
    'anxiety_relief': 'Alívio de Ansiedade & Estresse',
    'focus_productivity': 'Foco & Produtividade no Trabalho',
    'memory_improvement': 'Memória & Redução de Esquecimentos',
    'speed_clarity': 'Raciocínio Rápido & Clareza',
    'prevent_decline': 'Prevenção de Declínio Mental',
  };

  static const Map<String, String> symptomLabels = {
    'racing_thoughts': 'Pensamentos Acelerados / Insônia',
    'brain_fog': 'Névoa Mental & Cansaço Cognitivo',
    'digital_distraction': 'Distração Crônica com Telas',
    'forgetfulness': 'Falhas de Memória no Cotidiano',
  };

  static const Map<String, String> stressLabels = {
    'rarely': 'Raramente (1-2x ao mês)',
    'sometimes': 'Às vezes (1-2x por semana)',
    'daily': 'Quase todos os dias',
    'constant': 'O tempo todo / Sobrecarga alta',
  };

  static SurveyAnalyticsReport generateReport(List<OnboardingSurveyData> dataset) {
    if (dataset.isEmpty) {
      return const SurveyAnalyticsReport(
        totalCount: 0,
        goalPercentages: {},
        symptomPercentages: {},
        stressFrequencyPercentages: {},
        commitmentPercentages: {},
      );
    }

    final total = dataset.length;

    // 1. Contagens
    final goalCounts = <String, int>{};
    final symptomCounts = <String, int>{};
    final stressCounts = <String, int>{};
    final commitmentCounts = <String, int>{};

    for (final item in dataset) {
      final goalLabel = goalLabels[item.primaryGoal] ?? item.primaryGoal;
      goalCounts[goalLabel] = (goalCounts[goalLabel] ?? 0) + 1;

      final symptomLabel = symptomLabels[item.dominantSymptom] ?? item.dominantSymptom;
      symptomCounts[symptomLabel] = (symptomCounts[symptomLabel] ?? 0) + 1;

      final stressLabel = stressLabels[item.stressFrequency] ?? item.stressFrequency;
      stressCounts[stressLabel] = (stressCounts[stressLabel] ?? 0) + 1;

      final commitKey = '${item.dailyCommitmentMinutes} min/dia';
      commitmentCounts[commitKey] = (commitmentCounts[commitKey] ?? 0) + 1;
    }

    // 2. Cálculo de Porcentagens com 1 casa decimal
    Map<String, double> toPercentages(Map<String, int> counts) {
      final result = <String, double>{};
      counts.forEach((key, count) {
        final pct = double.parse(((count / total) * 100).toStringAsFixed(1));
        result[key] = pct;
      });
      return result;
    }

    return SurveyAnalyticsReport(
      totalCount: total,
      goalPercentages: toPercentages(goalCounts),
      symptomPercentages: toPercentages(symptomCounts),
      stressFrequencyPercentages: toPercentages(stressCounts),
      commitmentPercentages: toPercentages(commitmentCounts),
    );
  }

  static String exportDatasetJson(List<OnboardingSurveyData> dataset) {
    final report = generateReport(dataset);
    final rawList = dataset.map((e) => e.toMap()).toList();

    final exportObj = {
      'exportedAt': DateTime.now().toIso8601String(),
      'summary': report.toMap(),
      'records': rawList,
    };

    return const JsonEncoder.withIndent('  ').convert(exportObj);
  }

  /// Retorna uma amostra de pesquisa agregada (benchmark) representativa para estudos
  static List<OnboardingSurveyData> getSampleResearchDataset() {
    final baseTime = DateTime(2026, 11, 1);
    return [
      OnboardingSurveyData(
        primaryGoal: 'anxiety_relief',
        dominantSymptom: 'racing_thoughts',
        stressFrequency: 'daily',
        dailyCommitmentMinutes: 5,
        completedAt: baseTime,
      ),
      OnboardingSurveyData(
        primaryGoal: 'anxiety_relief',
        dominantSymptom: 'digital_distraction',
        stressFrequency: 'constant',
        dailyCommitmentMinutes: 10,
        completedAt: baseTime,
      ),
      OnboardingSurveyData(
        primaryGoal: 'anxiety_relief',
        dominantSymptom: 'brain_fog',
        stressFrequency: 'daily',
        dailyCommitmentMinutes: 10,
        completedAt: baseTime,
      ),
      OnboardingSurveyData(
        primaryGoal: 'focus_productivity',
        dominantSymptom: 'digital_distraction',
        stressFrequency: 'sometimes',
        dailyCommitmentMinutes: 10,
        completedAt: baseTime,
      ),
      OnboardingSurveyData(
        primaryGoal: 'memory_improvement',
        dominantSymptom: 'forgetfulness',
        stressFrequency: 'sometimes',
        dailyCommitmentMinutes: 15,
        completedAt: baseTime,
      ),
    ];
  }
}
