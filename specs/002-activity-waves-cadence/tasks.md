# Tasks: 5 Atividades em Ondas de 3 Desafios & Cadência de 5 Horas

**Input**: Design documents from `specs/002-activity-waves-cadence/` (`spec.md` & `plan.md`)  
**Prerequisites**: `spec.md`, `plan.md`  
**Organization**: Decomposição em User Stories Scrum com fatiamento vertical fino para máxima eficiência de tokens.

---

## Sprint 1: Modelos de Onda, Desafios & Cadência de 5 Horas (US1, US2)
- [x] **T001** [P] [US2] Criar modelos `WaveChallenge`, `ChallengeType`, `ChallengeRoundConfig` e `CognitiveWaveState` em `lib/models/wave_models.dart`.
- [x] **T002** [P] [US1] Criar modelo `ActivityCadence` em `lib/models/activity_cadence.dart` representando 5 slots por ciclo de 5h.
- [x] **T003** [US1] Implementar `CadenceService` em `lib/services/cadence_service.dart` com cálculo de ciclo de 5h, consumo de atividade, recarga periódica e suporte a VIP.
- [x] **T004** [US1] Escrever testes unitários em `test/cadence_service_test.dart` validando as regras do ciclo de 5 horas e limite de 5 atividades.

---

## Sprint 2: Minijogos Cognitivos com 3 a 7 Rodadas & Round 1 Explicativo (US2, US3)
- [x] **T005** [US3] Adaptar `lib/games/flash_matrix_game.dart` para suportar modo onda de 3 a 7 rodadas e banner explicativo na Rodada 1.
- [x] **T006** [US2, US3] Implementar minijogo `StroopReflexGame` em `lib/games/stroop_reflex_game.dart` (Efeito Stroop: inibição cognitiva com 3 a 7 rounds e tutorial na Rodada 1).
- [x] **T007** [US2, US3] Implementar minijogo `DigitSequenceGame` em `lib/games/digit_sequence_game.dart` (Memória sequencial de dígitos com 3 a 7 rounds e tutorial na Rodada 1).
- [x] **T008** [US2, US3] Escrever testes unitários em `test/stroop_reflex_test.dart` e `test/digit_sequence_test.dart`.

---

## Sprint 3: Orquestrador da Onda Cognitiva (US2)
- [x] **T009** [US2] Implementar tela orquestradora `WaveActivityScreen` em `lib/screens/wave_activity_screen.dart` que executa Desafio 1 -> Desafio 2 -> Desafio 3 em fluxo contínuo.
- [x] **T010** [US2] Adicionar modal/tela de resumo final com XP ganho, bônus de sequência e consumo do slot da atividade.

---

## Sprint 4: Widget de Cadência & Integração na Trilha e Perfil (US1)
- [x] **T011** [US1] Criar widget `ActivityCadenceBar` em `lib/widgets/activity_cadence_bar.dart` exibindo os 5 slots e o contador regressivo de 5h.
- [x] **T012** [US1] Integrar o acionamento de ondas na `HomeScreen` (ao clicar nos nós da trilha) e na `ProfileScreen`.

---

## Sprint 5: Qualidade, Build Web, Grafo & Versionamento
- [x] **T013** Executar `dart analyze lib` e garantir 0 issues.
- [x] **T014** Executar `flutter test` e garantir 100% dos testes aprovados (24 testes passando).
- [x] **T015** Recompilar web (`flutter build web --release`).
- [x] **T016** Atualizar grafo AST com `python -m graphify update .`.
- [x] **T017** Atualizar `checkpoint.md` e commitar no GitHub.
