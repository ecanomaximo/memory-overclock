# Arquitetura e Plano Técnico: Expansão de Jogos & Calibração Adaptativa

## Identificador: `005-adaptive-games-expansion`

---

## 1. Arquitetura da Calibração Cognitiva Adaptativa
Criar um módulo de calibração [`AdaptiveDifficultyProfile`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/models/adaptive_difficulty.dart):
- Lê os dados de `OnboardingSurveyData`:
  - `primaryGoal`: 'anxiety_relief', 'focus_productivity', 'memory_improvement', 'speed_clarity', etc.
  - `dominantSymptom`: 'racing_thoughts', 'brain_fog', 'digital_distraction', 'forgetfulness'.
  - `stressFrequency`: 'daily', 'often', 'sometimes', 'rarely'.
- Métricas derivadas:
  - `timeMultiplier`: `1.3` para ansiedade/estresse diário (tempo extra), `1.0` padrão, `0.9` para velocidade.
  - `recommendedGames`: prioriza os jogos conforme o domínio cognitivo.
  - `presentationDelayMs`: intervalo mais confortável para o usuário assimilar.

---

## 2. Ajustes nos Jogos Existentes
1. **`StroopReflexGame` & `ColorClashGame`:**
   - Paleta simplificada:
     - `VERMELHO`: `Color(0xFFFF334B)`
     - `AZUL`: `Color(0xFF2979FF)`
     - `VERDE`: `Color(0xFF00E676)`
     - `AMARELO`: `Color(0xFFFFD600)`
2. **`DigitSequenceGame`:**
   - Adicionar estado transitório de piscar `_isBlinking`:
     - Ao avançar o dígito, seta `_isBlinking = true` por 120ms (oculta ou pulsa o número com escala/fade) e depois exibe o novo dígito.
     - Permite que o jogador perceba claramente quando o mesmo número se repete.

---

## 3. Implementação dos Novos Jogos
1. **`VisualMemoryMatchGame` (`lib/games/visual_memory_game.dart`):**
   - Grade 4x3 (12 cartas = 6 pares) ou 4x4.
   - Ícones: `psychology` (cérebro), `bolt` (raio), `rocket_launch` (foguete), `diamond` (diamante), `star` (estrela), `crisis_alert` (alvo), `local_fire_department` (fogo), `lightbulb` (lâmpada).
   - Card com animação de flip/virar.
2. **`WordSearchGame` (`lib/games/word_search_game.dart`):**
   - Grade 7x7 ou 8x8 de letras.
   - 3 a 4 palavras escondidas na horizontal ou vertical.
   - Interação por toque nas letras para formar a palavra.

---

## 4. Integração na Sessão da Trilha (`WaveActivityScreen`)
- Adicionar os novos `ChallengeType.visualMemory` e `ChallengeType.wordSearch` no `WaveChallenge`.
- Injetar o perfil adaptativo da anamnese na criação da sessão.
