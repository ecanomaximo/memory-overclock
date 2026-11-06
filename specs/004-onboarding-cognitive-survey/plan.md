# Technical Plan: 004-onboarding-cognitive-survey

**Spec**: `specs/004-onboarding-cognitive-survey/spec.md`  
**Created**: 2026-11-05  
**Status**: Ready for Implementation  

---

## 1. Arquitetura Técnica & Componentes

```
┌────────────────────────────────────────────────────────┐
│                   App Navigation                       │
│        (main.dart - State Routing Listenable)          │
└──────────────────────────┬─────────────────────────────┘
                           │
             ┌─────────────┴─────────────┐
             ▼                           ▼
    [!isLoggedIn]                 [isLoggedIn]
     LoginScreen                         │
                           ┌─────────────┴─────────────┐
                           ▼                           ▼
                [!hasCompletedOnboarding]    [hasCompletedOnboarding]
                 OnboardingSurveyScreen          DashboardScreen
                           │                           │
                           ▼                           ▼
                 Salva no UserProgress          ProfileScreen
                 (OnboardingSurveyData)    (Mostra Diagnóstico &
                           │                 Acesso ao Analytics)
                           ▼                           │
                 SurveyAnalyticsService <──────────────┘
              (Calcula % e Extrai Dados)
```

---

## 2. Contratos de Dados & Modelos

### `lib/models/onboarding_survey.dart`
```dart
class OnboardingSurveyData {
  final String primaryGoal;          // 'anxiety', 'focus', 'memory', 'speed', 'longevity'
  final String dominantSymptom;      // 'accelerated_mind', 'brain_fog', 'screen_distraction', 'forgetfulness'
  final String stressFrequency;      // 'rarely', 'sometimes', 'daily', 'constant'
  final int dailyCommitmentMinutes;  // 5, 10, 15
  final DateTime completedAt;

  String get calculatedProfileTitle;
  String get recommendedFocusDomain;
  Map<String, dynamic> toMap();
  factory OnboardingSurveyData.fromMap(Map<String, dynamic> map);
}
```

### Atualização em `lib/models/user_progress.dart`
- Adicionar `final bool hasCompletedOnboarding;`
- Adicionar `final OnboardingSurveyData? surveyData;`
- Atualizar construtores, `copyWith`, `toMap()` e `fromMap()`.
- Retrocompatibilidade: se `hasCompletedOnboarding` for nulo no JSON persistido, herdar `true` se `currentLevel > 1`, ou `false` se for usuário recém-criado.

---

## 3. Lógica do Serviço Analítico (`SurveyAnalyticsService`)
- Entrada: lista de dados de questionários (usuário atual + base agregada amostral ou persistida).
- Métodos:
  - `Map<String, double> calculateGoalPercentages(List<OnboardingSurveyData> dataset)`
  - `Map<String, double> calculateStressFrequencyPercentages(List<OnboardingSurveyData> dataset)`
  - `Map<String, double> calculateCommitmentPercentages(List<OnboardingSurveyData> dataset)`
  - `String exportDatasetJson(List<OnboardingSurveyData> dataset)`: Exportação padronizada para estudos científicos e estatísticos posteriores.

---

## 4. UI & Ergonomia Cognitiva
- **`OnboardingSurveyScreen`**:
  - `PageView` com 4 perguntas + 1 tela final de diagnóstico.
  - Indicador de progresso no topo `Passo X de 4`.
  - Cards selecionáveis grandes com ícone, título e descrição do sintoma.
  - Centralizado em `maxWidth: 540` para ergonomia em mobile e desktop.
  - Botão "Continuar" desabilitado até que uma opção seja selecionada no passo corrente.
- **`SurveyAnalyticsModal`**:
  - Exibe barras de porcentagem por categoria:
    - Ansiedade & Sobrecarga: 55%
    - Foco & Produtividade: 28%
    - Memória & Esquecimentos: 17%
  - Botão para copiar JSON bruto para a área de transferência.

---

## 5. Estratégia de Testes
1. `test/onboarding_survey_test.dart`: Testar serialização, deserialização e cálculo do perfil diagnóstico.
2. `test/survey_analytics_service_test.dart`: Testar o cálculo das porcentagens e distribuição estatística.
3. `test/onboarding_navigation_test.dart`: Testar roteamento condicional no primeiro login vs login subsequente.
