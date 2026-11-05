# Implementation Plan: Memory Overclock Core Engine

**Branch**: `001-memory-overclock-core` | **Date**: 2026-11-05 | **Spec**: [specs/001-memory-overclock-core/spec.md](file:///c:/Users/emaxi/OneDrive/Área%20de%20Trabalho/claude/memory/specs/001-memory-overclock-core/spec.md)

---

## 1. Summary
Reconstrução completa, limpa e padronizada do aplicativo **Memory Overclock** em Flutter seguindo Spec-Driven Development, a filosofia Ponytail (menor código possível, zero código redundante) e cobertura de testes para lógica crítica de negócio. O app entrega a trilha de progressão Duolingo, minigame adaptativo Flash Matrix, mecânica de 3 desafios/dia com reset de meia-noite, Streak de dias consecutivos, Ligas Semanais de 30 jogadores e Paywall VIP.

---

## 2. Technical Context
- **Linguagem & SDK**: Dart `>=3.0.0 <4.0.0` / Flutter 3.x
- **Dependências Principais**:
  - `shared_preferences: ^2.2.2` (Persistência leve e offline-first)
  - `google_fonts: ^6.1.0` (Tipografia limpa e moderna - Orbitron / Inter / Roboto Mono)
  - `intl: ^0.19.0` (Formatação de datas e dias)
- **Design System**: Neon Cyberpunk Dark Theme (Fundo preto/grafite `#0A0E17`, Ciano Neon `#00F0FF`, Verde Neon `#00FFA3`, Roxo `#8A2BE2`, Rosa/Vermelho Neon `#FF0055`).
- **Arquitetura**: Model-Service-View desacoplada e reativa com `ChangeNotifier` ou `ValueNotifier` nativos do Flutter (zero dependências complexas de terceiros como Bloc/Riverpod desnecessárias para o escopo).
- **Testes**: `flutter_test` com cobertura de 100% nas regras de negócio críticas.

---

## 3. Constitution & Ponytail Check
| Princípio | Conformidade | Justificativa |
|---|---|---|
| I. SDD & Scrum | ✅ Pass | Especificação completa em `spec.md`, plano em `plan.md` e tarefas granulares em `tasks.md`. |
| II. Ponytail Minimalism | ✅ Pass | Utilização de `ValueNotifier` e `ChangeNotifier` nativos; sem wrappers ou boilerplate supérfluo. |
| III. Test-Driven Rules | ✅ Pass | Testes unitários para `ProgressService` (streak, limites diários, XP) e `LeagueService` (ranking e promoções). |
| IV. Checkpoint | ✅ Pass | `checkpoint.md` na raiz com histórico e ponto de parada. |
| V. Engaging Cognitive UX | ✅ Pass | Trilha visual sinuosa com CustomPainter, pulso neon e micro-feedbacks táteis. |

---

## 4. Estrutura de Arquivos Planejada
```text
lib/
├── main.dart                      # Ponto de entrada, inicialização de tema e serviços
├── theme/
│   └── app_theme.dart             # Cores neon, tema escuro e estilos de texto
├── models/
│   ├── phase_node.dart            # Modelo da fase (id, título, tipo boss/normal, x/y, status)
│   ├── user_progress.dart         # Estado do jogador (fase, xp, streak, limites, vip)
│   ├── league_player.dart         # Competidor do ranking semanal
│   └── league_model.dart          # Estado da liga semanal e divisões
├── services/
│   ├── progress_service.dart      # Regras de limite 3/dia, streak, XP e persistência
│   └── league_service.dart        # Geração de 30 jogadores, ordenação e promoção
├── widgets/
│   ├── path_painter.dart          # Pintor do caminho curvo da trilha
│   ├── phase_node_widget.dart     # Widget do nó da fase (pulsante, neon, bloqueado)
│   └── top_bar_stats.dart         # Barra superior com Streak, Vidas/Desafios e XP
├── games/
│   └── flash_matrix_game.dart     # Minigame adaptativo de memória de trabalho
└── screens/
    ├── dashboard_screen.dart      # Shell principal de abas (Trilha, Liga, VIP)
    ├── home_screen.dart           # Trilha estilo Duolingo
    ├── league_screen.dart         # Tela de Ligas Semanais (Top 7 / Bottom 5)
    └── paywall_screen.dart        # Modal/tela de Assinatura VIP
test/
├── progress_service_test.dart     # Testes de limites, resets diários, streak e XP
└── league_service_test.dart       # Testes de ordenação de ranking, XP e promoção
```

---

## 5. Estratégia de Implementação (Fatiamento Scrum)
A implementação será realizada em **5 Sprints / Fatias Verticais**:
1. **Slice 1 (Core Domain & Testes Unitários):** Modelos de dados e `ProgressService` com persistência local e testes unitários completos.
2. **Slice 2 (Engine do Minigame de Memória):** `FlashMatrixGame` com mecânica adaptativa, contagem de vidas, feedback visual imediato e pontuação.
3. **Slice 3 (Trilha de Progressão Duolingo):** `PathPainter`, `PhaseNodeWidget` e `HomeScreen` integradas ao `ProgressService`.
4. **Slice 4 (Ligas Competitivas Semanais):** `LeagueService` e `LeagueScreen` com cálculo reativo de posições e faixas de promoção.
5. **Slice 5 (Paywall VIP & Integração do Shell):** `PaywallScreen`, `DashboardScreen`, validação geral `dart analyze` e `graphify update .`.
