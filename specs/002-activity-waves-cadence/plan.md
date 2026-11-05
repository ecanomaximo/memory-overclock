# Implementation Plan: 5 Atividades em Ondas de 3 Desafios & Cadência de 5 Horas

**Branch**: `main` | **Date**: 2026-11-05 | **Spec**: [specs/002-activity-waves-cadence/spec.md](file:///c:/Users/emaxi/OneDrive/Área%20de%20Trabalho/claude/memory/specs/002-activity-waves-cadence/spec.md)

---

## 1. Sumário Executivo
Este plano especifica a arquitetura técnica para fornecer **5 atividades cognitivas por ciclo de 5 horas**.  
Cada atividade é uma **Onda Cognitiva ("Cognitive Wave")** contendo **3 desafios distintos**:
1. **Flash Matrix** (Memória de Trabalho Espacial)
2. **Stroop Reflex** (Controle Inibitório Pré-Frontal)
3. **Digit Sequence** (Memória Numérica de Curto Prazo)

Cada desafio opera com **3 a 7 rodadas progressivas**, sendo a **primeira rodada fácil e explicativa (com tutorial visual rápido)** e as seguintes aumentando em complexidade e velocidade.

---

## 2. Decisões Arquiteturais & Ponytail Check

| Princípio / Diretriz | Decisão Técnica | Benefício |
|---|---|---|
| **Ponytail Minimalism** | Minijogos estruturados em widgets Flutter reativos padrão (`StatefulWidget` com timers nativos de Dart `async`). Sem dependências pesadas de engines (Flame/Unity). | Código enxuto, < 250 linhas por jogo, 60fps no Flutter Web. |
| **Cadência de 5 Horas** | `CadenceService` calcula `cycleStartTime` e `nextRefreshTime = cycleStartTime.add(Duration(hours: 5))`. Se `now >= nextRefreshTime`, reseta cota para 5 atividades. | Lógica matemática testável e pura. Suporte a VIP (recarga instantânea). |
| **Progresso da Onda (Wave)** | `WaveActivityScreen` atua como orquestrador de estado da onda. Executa sequencialmente Desafio 1 -> Desafio 2 -> Desafio 3. Se o jogador passar em todos, conclui a atividade e credita XP. | Separação limpa entre a orquestração da onda e os minijogos individuais. |
| **Dificuldade Progressiva** | `ChallengeRoundConfig` parametriza cada round (tutorial: bool, tempo de exposição, tamanho do estímulo, distratores). | Reutilização do mesmo componente de jogo para diferentes níveis de dificuldade. |

---

## 3. Estrutura de Arquivos Planejada

```text
lib/
├── models/
│   ├── activity_cadence.dart      # Estado das 5 atividades e timer de 5h
│   └── wave_models.dart           # Modelos de onda, desafios e configuração de rodadas
├── services/
│   └── cadence_service.dart       # Lógica do ciclo de 5h, consumo de atividade e timer
├── games/
│   ├── flash_matrix_game.dart     # Minijogo 1: Memória espacial (adaptado para rodadas)
│   ├── stroop_reflex_game.dart    # Minijogo 2: Inibição de impulso (Stroop effect)
│   └── digit_sequence_game.dart   # Minijogo 3: Sequência numérica rápida
├── screens/
│   └── wave_activity_screen.dart  # Shell da Onda (orquestra Desafio 1 -> 2 -> 3)
└── widgets/
    └── activity_cadence_bar.dart  # Widget de visualização dos 5 slots e timer regressivo
test/
├── cadence_service_test.dart      # Testes da lógica de 5h e consumo de slots
├── stroop_reflex_test.dart        # Testes de regras do Stroop
└── digit_sequence_test.dart       # Testes da sequência numérica
```

---

## 4. Estratégia de Testes Unitários
- Teste de recarga de 5h (quando passa de 5h, slots voltam para 5).
- Teste de consumo de slot (cada atividade concluída consome 1 slot).
- Teste de progressão da onda (desafio 1 -> desafio 2 -> desafio 3 -> conclusão de onda).
- Teste de concessão de XP ao término da onda (com bônus VIP de 1.5x).
