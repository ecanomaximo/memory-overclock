# Tasks: Memory Overclock Core Engine

**Input**: Design documents from `specs/001-memory-overclock-core/` (`spec.md` & `plan.md`)  
**Prerequisites**: `spec.md`, `plan.md`, `constitution.md`  
**Organization**: Decomposição em User Stories Scrum com fatiamento vertical fino para máxima eficiência de tokens.

---

## Sprint 1: Setup & Core Business Rules (US3 - Desafios Diários & Streak)
- [x] **T001** [P] [Setup] Criar tema neon cyberpunk e estilos de tipografia em `lib/theme/app_theme.dart`.
- [x] **T002** [P] [US3] Implementar modelo de dados `UserProgress` em `lib/models/user_progress.dart`.
- [x] **T003** [US3] Implementar `ProgressService` em `lib/services/progress_service.dart` com cálculo de 3 desafios/dia (10 para VIP), reset de meia-noite, cálculo de streak contínuo e persistência offline em `SharedPreferences`.
- [x] **T004** [US3] Escrever suite de testes unitários em `test/progress_service_test.dart` e validar regras de negócio críticas.

---

## Sprint 2: Minigame de Memória de Trabalho (US2 - Flash Matrix Game)
- [x] **T005** [US2] Implementar minigame cognitivo adaptativo `FlashMatrixGame` em `lib/games/flash_matrix_game.dart` com grade dinâmica (3x3 a 5x5), tempos de exposição por nível, sistema de vidas e cálculo de XP.
- [x] **T006** [US2] Implementar testes unitários do motor do minigame em `test/flash_matrix_test.dart`.

---

## Sprint 3: Trilha de Fases Estilo Duolingo (US1 - Trilha & Nós Interativos)
- [x] **T007** [P] [US1] Implementar modelo de nós de fase `PhaseNode` em `lib/models/phase_node.dart`.
- [x] **T008** [P] [US1] Implementar pintor vetorial de curvas de Bézier em `lib/widgets/path_painter.dart`.
- [x] **T009** [US1] Implementar widget de nó interativo em `lib/widgets/phase_node_widget.dart` com pulso animado para fase atual, visual verde neon para concluídas, cinza para bloqueadas e ícone para chefes.
- [x] **T010** [P] [US1] Implementar barra superior de estatísticas em `lib/widgets/top_bar_stats.dart` exibindo 🔥 Streak, ⚡ Desafios Diários e 🧠 XP.
- [x] **T011** [US1] Implementar tela da trilha `HomeScreen` em `lib/screens/home_screen.dart` com rolagem vertical, checagem de limite diário e acionamento de minigame.

---

## Sprint 4: Ligas Competitivas Semanais (US4 - Ranking de 30 Jogadores)
- [x] **T012** [P] [US4] Implementar modelos da liga `LeaguePlayer` e `LeagueModel` em `lib/models/league_player.dart` e `lib/models/league_model.dart`.
- [x] **T013** [US4] Implementar `LeagueService` em `lib/services/league_service.dart` com geração determinística de 30 concorrentes, ordenação de ranking, zonas de promoção (Top 7) e rebaixamento (Últimos 5).
- [x] **T014** [US4] Escrever suite de testes unitários para a liga em `test/league_service_test.dart`.
- [x] **T015** [US4] Implementar tela de ranking `LeagueScreen` em `lib/screens/league_screen.dart` com cards neon, marcadores de zona e contagem regressiva da temporada.

---

## Sprint 5: Monetização VIP, Shell da Aplicação & Integração (US5)
- [x] **T016** [US5] Implementar tela de paywall `PaywallScreen` em `lib/screens/paywall_screen.dart` com lista de benefícios VIP (10 desafios/dia, 1.5x XP) e alternador para testes.
- [x] **T017** [US5] Implementar shell principal de navegação `DashboardScreen` em `lib/screens/dashboard_screen.dart` com bottom navigation bar estilizada.
- [x] **T018** [US5] Atualizar `lib/main.dart` com inicialização limpa de serviços, injeção de dependências e tema global.

---

## Sprint 6: Convergência, Qualidade & Sincronização do Grafo
- [x] **T019** Executar `dart analyze lib` e garantir conformidade com 0 erros.
- [x] **T020** Executar `flutter test` e garantir 100% de aprovação dos testes unitários (14 testes passando).
- [x] **T021** Atualizar o grafo de conhecimento com `python -m graphify update .`.
- [x] **T022** Atualizar `checkpoint.md` documentando todas as alterações entregues.
