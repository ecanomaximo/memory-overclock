# Especificação da Funcionalidade: Expansão de Jogos & Calibração Cognitiva Adaptativa

## Identificador: `005-adaptive-games-expansion`
**Status:** Concluído & Homologado (Fechado)  
**Data:** 06/11/2026  
**Metodologia:** Spec-Driven Development (SDD) & Scrum Slicing

---

## 1. Visão Geral do Produto
Esta especificação atende às melhorias ergonômicas e à expansão de conteúdo do **Memory Overclock**:
1. **Calibração Cognitiva Adaptativa:** Ajustar a sessão de treinos (tempo de resolução, seleção de jogos e ritmo) com base nas respostas da Anamnese Neural (`OnboardingSurveyData`) do jogador.
2. **Melhoria no Jogo de Dígitos (Digit Span):** Implementar efeito visual de piscar/pulso luminoso a cada transição de número para que dígitos idênticos consecutivos sejam inconfundíveis.
3. **Simplificação Cromática no Jogo de Cores:** Substituir cores complexas (ciano, menta, âmbar, magenta) pelo quarteto universal de cores primárias claras: **Vermelho, Azul, Verde e Amarelo**.
4. **Novos Jogos:**
   - **Jogo da Memória com Imagens:** Grade de cartas neurocognitivas viradas para baixo para encontrar pares.
   - **Caça-Palavras Cognitivo:** Grade interativa com palavras-chave de foco, atenção e memória.

---

## 2. User Stories (Formato Scrum)

### US-01: Calibração Adaptativa com Base na Anamnese
- **Como** jogador com sintomas específicos (ex: ansiedade, pensamentos acelerados ou perda de foco),
- **Quero** que a dificuldade e o ritmo dos jogos se adaptem ao meu perfil de respostas,
- **Para que** meu treino seja relaxante se estou ansioso (mais tempo, menos pressão) ou estimulante se busco velocidade/hiperfoco.

**Critérios de Aceite:**
- [ ] Jogadores com meta de "Alívio de Ansiedade" ou estresse frequente recebem tempos de resolução estendidos (30% a mais) e menor punição de tempo.
- [ ] Jogadores com sintoma dominante de "Esquecimento" recebem mais foco em jogos de memória (Jogo da Memória, Flash Matrix e Dígitos).
- [ ] Jogadores focados em "Hiperfoco & Produtividade" recebem desafios de atenção sustentada (Caça-Palavras e Stroop).

---

### US-02: Indicação Visual de Dígito Repetido (Piscar / Pulse)
- **Como** jogador do jogo de sequência de dígitos,
- **Quero** ver o número piscar ou pulsar distintamente a cada avanço,
- **Para que** eu identifique claramente quando o mesmo dígito aparece duas vezes seguidas (ex: 7 e 7).

**Critérios de Aceite:**
- [ ] Ao mudar de dígito, o card executa um flash/piscar de opacidade ou escala perceptível (120-150ms).
- [ ] Teste visual garante que números repetidos são claramente distinguidos.

---

### US-03: Cores Primárias Universais & Progressão Adaptativa por Fase
- **Como** jogador do Desafio de Cores (Stroop & Color Clash),
- **Quero** começar nas primeiras fases com as 4 cores primárias mais fáceis (Vermelho, Azul, Verde, Amarelo) e ver a dificuldade e número de cores aumentarem conforme avanço de fase,
- **Para que** o início seja acessível e intuitivo, tornando-se progressivamente mais desafiador.

**Critérios de Aceite:**
- [x] Fases 1 a 3 (Iniciante): Quarteto primário básico (**VERMELHO**, **AZUL**, **VERDE**, **AMARELO**).
- [x] Fases 4 a 6 (Intermediário): Adição de +2 cores (**LARANJA**, **ROXO**).
- [x] Fases 7+ (Avançado): Adição de +3 cores de tom aproximado (**CIANO**, **MENTA**, **MAGENTA**), demandando máximo esforço inibitório.
- [x] Demais jogos adaptados proporcionalmente por nível:
  - `DigitSequenceGame`: 3 dígitos base nos níveis 1-3 até 5+ dígitos nos níveis 7+ com tempo de exibição mais rápido.
  - `VisualMemoryMatchGame`: 4 pares (8 cartas) nos níveis 1-3; 6 pares (12 cartas) nos níveis 4-6; 8 pares (16 cartas) nos níveis 7+.
  - `WordSearchGame`: 2 palavras nos níveis 1-3; 3 palavras nos níveis 4-6; 4 palavras nos níveis 7+.
  - `FlashMatrixWaveChallenge`: 3x3 e 3 alvos nos níveis 1-3; 4x4 e 4-6 alvos nos níveis 4-6; até 5x5 e 7 alvos nos níveis 7+.

---

### US-04: Jogo da Memória com Emojis, Flip 3D & Pré-visualização
- **Como** jogador,
- **Quero** virar pares de cartas com emojis do WhatsApp com animação de flip 3D, ver um preview inicial de até 30 segundos com todas as cartas reveladas e ter o número de fileiras escalando de 3 para 4 e 5 fileiras,
- **Para que** eu exercite a memória de curto prazo e reconhecimento visual com clareza e ritmo personalizável.

**Critérios de Aceite:**
- [x] Utilização de **emojis expressivos do WhatsApp** (🧠, ⚡, 🚀, 💎, ⭐, 🎯, 🔥, 💡, 🧩, 🏆, 👑, 🦄, 🪐, 🍕, 🐱, 🥑) com rótulos e bordas neon.
- [x] **Animação 3D de virada (Flip)**: Ao tocar na carta, rotação suave em torno do eixo Y (`Transform` com perspectiva) com frente e verso distintos.
- [x] **Pré-visualização Inicial de 30 segundos**: Ao iniciar o desafio, todas as cartas abertas com barra regressiva e botão "COMEÇAR AGORA" para fechar e iniciar as tentativas imediatamente se o jogador já tiver memorizado.
- [x] **Escala de fileiras**: 3 fileiras no 1º desafio (12 cartas = 6 pares), 4 fileiras no 2º desafio (16 cartas = 8 pares) e 5 fileiras no 3º desafio (20 cartas = 10 pares).

---

### US-05: Caça-Palavras Cognitivo (Word Search)
- **Como** jogador,
- **Quero** localizar palavras escondidas em uma grade de letras,
- **Para que** eu treine atenção sustentada e escaneamento visual.

**Critérios de Aceite:**
- [ ] Grade de letras com palavras cognitivas (FOCO, MENTE, MEMORIA, AGIL, TREINO).
- [ ] Feedback visual com seleção de letras e marcação de palavras concluídas.
