# Tasks: Expansão de Jogos & Calibração Cognitiva Adaptativa

## Sprint 1: Calibração Adaptativa & Melhorias Ergonômicas dos Jogos Existentes
- [x] **T001** [US-01] Criar modelo [`AdaptiveDifficultyProfile`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/models/adaptive_difficulty.dart) para calibrar tempos e foco a partir das respostas do questionário.
- [x] **T002** [US-02] Adicionar efeito de piscar/pulso no [`DigitSequenceGame`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/games/digit_sequence_game.dart) para números repetidos consecutivos.
- [x] **T003** [US-03] Substituir paleta de cores complexas por cores primárias simples (Vermelho, Azul, Verde, Amarelo) em [`StroopReflexGame`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/games/stroop_reflex_game.dart) e [`ColorClashGame`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/games/color_clash_game.dart).

---

## Sprint 2: Novos Jogos Neurocognitivos
- [x] **T004** [US-04] Implementar [`VisualMemoryMatchGame`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/games/visual_memory_game.dart) (jogo da memória de pares com ícones/imagens).
- [x] **T005** [US-05] Implementar [`WordSearchGame`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/games/word_search_game.dart) (caça-palavras cognitivo interativo).
- [x] **T006** Integrar os novos jogos no enum [`ChallengeType`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/models/wave_models.dart) e no loop da sessão [`WaveActivityScreen`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/screens/wave_activity_screen.dart).

---

## Sprint 3: Testes, Validação & Deploy
- [x] **T007** Escrever testes unitários para a calibração adaptativa e para os novos componentes de jogo (`test/adaptive_games_test.dart`).
- [x] **T008** Rodar `dart analyze lib test` e `flutter test` (44/44 testes passando).
- [x] **T009** Compilar Web (`flutter build web --release --base-href "/memory-overclock/"`) e publicar na branch `gh-pages`.
- [x] **T010** Atualizar `checkpoint.md` e sincronizar AST com `python -m graphify update .`.
