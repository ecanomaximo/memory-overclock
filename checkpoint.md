# 📍 Checkpoint do Projeto: Memory Overclock

**Data:** 05/11/2026  
**Status do Projeto:** Concluído (Marco: Correção de Bloqueio de Retry no Stroop & Expansão de Tempo para 60s-90s)

---

## 1. O Que Foi Feito Nesta Sessão
1. **Correção do Bloqueio de Retry (Tela Travada ao Perder):**
   - **Diagnóstico:** O widget `KeyedSubtree` em `WaveActivityScreen` mantinha a mesma chave `ValueKey('g_0_r_1')` quando a rodada falhava ou a bateria reiniciava na rodada 1, fazendo com que o Flutter recicl会上 o estado `_StroopReflexGameState` com `_answered = true` e os timers cancelados, ignorando novos cliques.
   - **Correção:** Introduzido `_attemptCounter` dinâmico na chave do `KeyedSubtree` (`ValueKey('g_${_currentChallengeIndex}_r_${_currentRound}_a_$_attemptCounter')`). A cada falha ou reinício de bateria, a chave é invalidada, garantindo a recriação limpa e imediata do widget de desafio, novo estímulo e timers reiniciados.
   - Adicionada notificação `didUpdateWidget` em `StroopReflexGame` para garantir consistência.
2. **Aumento Generoso do Tempo de Resolução (60s a 90s):**
   - **Seleção de Cores (Stroop Reflex - `lib/games/stroop_reflex_game.dart`):**
     - Rodada 1 (Tutorial): Elevado para **90 segundos (1 minuto e meio)**.
     - Rodadas 2 a 5: Faixa progressiva relaxada entre **75 segundos e 60 segundos (1 minuto)**.
     - Adicionado indicador visual textual de contagem regressiva: `XXs restantes`.
   - **Flash Matrix (`lib/games/flash_matrix_game.dart`):**
     - Tempo de memorização na Rodada 1 elevado para **6.0 segundos** e rodadas avançadas entre **5.0s e 3.0s**.
3. **Qualidade & Testes:**
   - Teste unitário `test/stroop_reflex_test.dart` atualizado e aprovado.
   - `dart analyze lib`: 0 erros, 0 warnings.
   - `flutter test`: 29 testes aprovados (100% de sucesso).
4. **Deploy & Publicação:**
   - Recompilado `flutter build web --release --base-href "/memory-overclock/"`.
   - Publicado na branch `gh-pages` e disponível em tempo real no GitHub Pages (`https://ecanomaximo.github.io/memory-overclock/`).
   - Grafo Graphify atualizado para 1780 nós e 1991 arestas.

---

## 2. Onde Parou
- As correções de retry e os tempos ampliados de 60s a 90s estão 100% ativos e funcionais no ar.
- Servidor web e GitHub Pages atualizados.

---

## 3. Contexto Técnico Atual
- **Branch:** `main` (código-fonte) / `gh-pages` (distribuição pública)
- **Local Web Server:** `http://localhost:8085/`
- **URL Pública Oficial:** `https://ecanomaximo.github.io/memory-overclock/`
- **Testes:** 29 testes passando.
- **Grafo:** `graphify-out/` com 1780 nós.

---

## 4. Próximos Passos
1. Integração com Firebase Console para credenciais reais de produção caso o usuário decida vincular seu projeto.
2. Adicionar efeitos sonoros sutis de neurofeedback para acertos e combo streaks.
