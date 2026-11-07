# 📍 Checkpoint do Projeto: Memory Overclock

**Data:** 06/11/2026  
**Status do Projeto:** Concluído (Expansão de Jogos, Calibração Cognitiva Adaptativa e Novo Deploy no Ar)

---

## 1. O Que Foi Feito Nesta Sessão
1. **Calibração Cognitiva Adaptativa (Anamnese ➔ Gameplay):**
   - Criado [`AdaptiveDifficultyProfile`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/models/adaptive_difficulty.dart) conectando as respostas da Anamnese Neural (`OnboardingSurveyData`) à dinâmica da sessão.
   - Perfis de alívio de ansiedade e alto estresse recebem +35% de tempo e ritmo calmo com jogos relaxantes. Perfis com esquecimento recebem foco em retenção mnemônica.
   - Badge explicativo com o tipo de calibração exibido no topo da sessão de treino.
2. **Piscar / Pulso nos Números Repetidos (`DigitSequenceGame`):**
   - Implementado efeito de piscar com `AnimatedOpacity` e `AnimatedScale` (160ms) no [`DigitSequenceGame`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/games/digit_sequence_game.dart) a cada transição, permitindo identificar com clareza números consecutivos repetidos (ex: 5 e 5).
   - Adicionado contador de progresso "Dígito X de Y".
3. **Cores Primárias Simples no Jogo de Cores:**
   - Paleta complexa substituída pelo quarteto universal: **Vermelho**, **Azul**, **Verde** e **Amarelo** em [`StroopReflexGame`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/games/stroop_reflex_game.dart) e [`ColorClashGame`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/games/color_clash_game.dart).
4. **Dois Novos Jogos Neurocognitivos Adicionados:**
   - **`VisualMemoryMatchGame` (`lib/games/visual_memory_game.dart`):** Jogo da memória visual com cartas viradas para baixo e ícones neurais (cérebro, raio, foguete, diamante, estrela, alvo).
   - **`WordSearchGame` (`lib/games/word_search_game.dart`):** Caça-palavras cognitivo em grade 8x8 com palavras-chave de foco, atenção e clareza.
5. **Qualidade & Rastreabilidade:**
   - 44 testes automatizados passando 100% (`flutter test`).
   - `dart analyze lib test`: 0 erros / 0 avisos.
   - Grafo de conhecimento Graphify atualizado (1.991 nós, 2.274 arestas).
   - Build web compilado e publicado na branch `gh-pages`.

---

## 2. Onde Parou
- Todas as melhorias visuais, os dois novos jogos e a calibração adaptativa estão compilados e no ar para teste imediato.

---

## 3. Contexto Técnico Atual
- **Jogos Disponíveis (5 tipos):**
  1. Seleção de Cores (Stroop com cores primárias)
  2. Jogo da Memória Visual (Cartas com ícones)
  3. Flash Matrix (Matriz espacial)
  4. Caça-Palavras Cognitivo (Grid 8x8)
  5. Memória Numérica (Digit Span com piscar luminoso)
- **URL Pública:** `https://ecanomaximo.github.io/memory-overclock/`
- **Testes:** 44/44 aprovados.

---

## 4. Próximos Passos
1. Jogar uma sessão completa na trilha para experimentar a rotação dos 5 jogos e a calibração personalizada.
