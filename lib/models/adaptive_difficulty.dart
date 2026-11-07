import 'onboarding_survey.dart';

/// Perfil de Dificuldade Adaptativa calculado a partir da Anamnese Cognitiva do Jogador.
class AdaptiveDifficultyProfile {
  final double timeMultiplier;
  final int bonusSeconds;
  final String primaryGoal;
  final String dominantSymptom;
  final String stressFrequency;
  final String recommendationNotice;

  const AdaptiveDifficultyProfile({
    this.timeMultiplier = 1.0,
    this.bonusSeconds = 0,
    this.primaryGoal = 'focus_productivity',
    this.dominantSymptom = 'digital_distraction',
    this.stressFrequency = 'sometimes',
    this.recommendationNotice = 'Sessão equilibrada com ritmo neurocognitivo padrão.',
  });

  factory AdaptiveDifficultyProfile.fromSurvey(OnboardingSurveyData? survey) {
    if (survey == null) {
      return const AdaptiveDifficultyProfile();
    }

    double multiplier = 1.0;
    int extraSeconds = 0;
    String notice = 'Sessão equilibrada com foco neurocognitivo adaptativo.';

    // Regulação para Alívio de Ansiedade / Estresse Elevado
    if (survey.primaryGoal == 'anxiety_relief' || survey.stressFrequency == 'daily') {
      multiplier = 1.35;
      extraSeconds = 30;
      notice = '🌿 Calibração Anti-Ansiedade: ritmo despressurizado (+35% de tempo) para treino calmo e focado.';
    } else if (survey.primaryGoal == 'speed_clarity') {
      multiplier = 0.9;
      extraSeconds = 0;
      notice = '⚡ Calibração Neuro-Speed: estímulos velozes e reflexo dinâmico de alta precisão.';
    } else if (survey.dominantSymptom == 'forgetfulness' || survey.primaryGoal == 'memory_improvement') {
      multiplier = 1.20;
      extraSeconds = 20;
      notice = '🧠 Calibração Mnemônica: tempo de retenção estendido para consolidação de memória.';
    } else if (survey.dominantSymptom == 'racing_thoughts') {
      multiplier = 1.25;
      extraSeconds = 20;
      notice = '🎯 Calibração Controle Inibitório: ritmo controlado para estabilização de pensamentos.';
    }

    return AdaptiveDifficultyProfile(
      timeMultiplier: multiplier,
      bonusSeconds: extraSeconds,
      primaryGoal: survey.primaryGoal,
      dominantSymptom: survey.dominantSymptom,
      stressFrequency: survey.stressFrequency,
      recommendationNotice: notice,
    );
  }
}
