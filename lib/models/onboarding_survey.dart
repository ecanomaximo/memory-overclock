import 'package:flutter/material.dart';

class OnboardingQuestionOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const OnboardingQuestionOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingSurveyData {
  final String primaryGoal;
  final String dominantSymptom;
  final String stressFrequency;
  final int dailyCommitmentMinutes;
  final DateTime completedAt;

  const OnboardingSurveyData({
    required this.primaryGoal,
    required this.dominantSymptom,
    required this.stressFrequency,
    required this.dailyCommitmentMinutes,
    required this.completedAt,
  });

  String get profileTitle {
    switch (primaryGoal) {
      case 'anxiety_relief':
        return 'Alívio de Ansiedade & Clareza Mental';
      case 'focus_productivity':
        return 'Hiperfoco & Produtividade';
      case 'memory_improvement':
        return 'Memória Operacional Reforçada';
      case 'speed_clarity':
        return 'Velocidade de Processamento';
      case 'prevent_decline':
        return 'Longevidade & Proteção Neural';
      default:
        return 'Treino Cognitivo Abrangente';
    }
  }

  String get recommendedFocusDomain {
    switch (dominantSymptom) {
      case 'racing_thoughts':
        return 'Controle Inibitório & Respiração';
      case 'brain_fog':
        return 'Velocidade e Resposta Rápida (Stroop)';
      case 'digital_distraction':
        return 'Atenção Sustentada e Foco Contínuo';
      case 'forgetfulness':
        return 'Memória de Trabalho Espacial (Flash Matrix)';
      default:
        return 'Resistência a Distrações';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'primaryGoal': primaryGoal,
      'dominantSymptom': dominantSymptom,
      'stressFrequency': stressFrequency,
      'dailyCommitmentMinutes': dailyCommitmentMinutes,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory OnboardingSurveyData.fromMap(Map<String, dynamic> map) {
    return OnboardingSurveyData(
      primaryGoal: map['primaryGoal'] as String? ?? 'focus_productivity',
      dominantSymptom: map['dominantSymptom'] as String? ?? 'digital_distraction',
      stressFrequency: map['stressFrequency'] as String? ?? 'sometimes',
      dailyCommitmentMinutes: (map['dailyCommitmentMinutes'] as num?)?.toInt() ?? 10,
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
