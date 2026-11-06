# Tasks: 004-onboarding-cognitive-survey

**Spec**: `specs/004-onboarding-cognitive-survey/spec.md`  
**Plan**: `specs/004-onboarding-cognitive-survey/plan.md`  
**Status**: Completed  

---

## Sprint Backlog (Tarefas Scrum)

- [x] **Task 1: Modelo de Dados do Questionário & Integração no UserProgress**
  - Criado `lib/models/onboarding_survey.dart` com opções de motivação, sintomas, frequência de ansiedade e cálculo de perfil.
  - Atualizado `lib/models/user_progress.dart` com `hasCompletedOnboarding` e `surveyData`.
  - Criado teste unitário `test/onboarding_survey_model_test.dart` (100% aprovado).

- [x] **Task 2: Motor Analítico de Cálculo de Porcentagens & Extração para Estudo**
  - Implementado `lib/services/survey_analytics_service.dart`.
  - Funções de cálculo de distribuição percentual (Objetivos, Ansiedade, Sintomas) e exportador JSON.
  - Criado teste unitário `test/survey_analytics_service_test.dart` (100% aprovado).

- [x] **Task 3: Interface do Questionário de Onboarding (Anamnese Cognitiva)**
  - Implementado `lib/screens/onboarding_survey_screen.dart` com 4 etapas fluidas e tela final de diagnóstico.
  - Aplicada contenção ergonômica (`maxWidth: 540`), cards táteis com feedback ciano/verde e barra de progresso.

- [x] **Task 4: Roteamento no 1º Acesso & Persistência no ProgressService**
  - Adicionado método `completeOnboarding(OnboardingSurveyData data)` em `lib/services/progress_service.dart`.
  - Atualizado `lib/main.dart` para rotear automaticamente novos usuários para o onboarding e usuários recorrentes para o dashboard.
  - Criado teste de integração de roteamento `test/onboarding_routing_test.dart` (100% aprovado).

- [x] **Task 5: Card de Perfil no Painel & Modal de Extração Analítica de Porcentagens**
  - Adicionado card "Diagnóstico Mental & Objetivo Primário" no `ProfileScreen`.
  - Criado modal `SurveyAnalyticsSheet` para visualizar as porcentagens consolidadas e botão para exportar dados do estudo em JSON.
  - Disponibilizado botão de acesso na barra superior e no corpo do Perfil.
  - Criado teste de widget `test/survey_analytics_sheet_test.dart` (100% aprovado).

- [x] **Task 6: Validação Global, Testes & Deploy de Produção**
  - Executado `dart analyze lib test` (0 issues).
  - Executado `flutter test` (37/37 testes aprovados).
  - Compilado `flutter build web --release --base-href "/memory-overclock/"`.
  - Publicado na branch `gh-pages` (commit `a31aa06`) e sincronizado `main`.
  - Atualizado `checkpoint.md` e sincronizado AST com `graphify`.
