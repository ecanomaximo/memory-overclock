# Feature Specification: Memory Overclock Core Engine

**Feature Branch**: `001-memory-overclock-core`  
**Created**: 2026-11-05  
**Status**: Approved  
**Input**: "Refaça o projeto todo agora com o mesmo intuito que ele começou, agora com as skills novas. Siga specs e faça tudo padronizado certinho."

---

## 1. Executive Summary
**Memory Overclock** é um aplicativo mobile em Flutter focado em aprimoramento cognitivo e treino da memória de trabalho (anti-brain rot). O aplicativo combina a psicologia de retenção do Duolingo (trilha sinuosa com nós interativos e ofensiva diária) com competição social (ligas semanais de 30 competidores) e monetização por escassez (3 desafios diários gratuitos, expansíveis para 10 no plano VIP).

---

## 2. User Scenarios & Testing *(Prioritized User Journeys)*

### User Story 1 - Trilha de Progressão Estilo Duolingo (Priority: P1)
**Como** usuário que busca evolução diária estruturada,  
**Quero** visualizar uma trilha ondulada com fases sequenciais e chefes periódicos,  
**Para que** eu sinta senso claro de conquista e progressão visual à medida que concluo desafios.

- **Why this priority:** A trilha é a tela central do jogo (Home/Hub), o principal ponto de contato e direcionamento do jogador.
- **Independent Test:** O usuário navega pela tela principal, visualiza os nós conectados por caminho contínuo, clica na fase liberada e vê as fases futuras bloqueadas.
- **Acceptance Scenarios:**
  1. **Given** o jogador no nível inicial (Fase 1 liberada), **When** ele conclui a Fase 1 com sucesso, **Then** a Fase 2 é desbloqueada e o nó da Fase 1 fica com status de "concluído" (verde neon).
  2. **Given** um nó bloqueado (Fase 3), **When** o jogador clica nele, **Then** o app exibe feedback de bloqueio sem iniciar o jogo.
  3. **Given** cada 5ª fase (ex: 5, 10, 15), **When** renderizada na trilha, **Then** exibe ícone distintivo de Chefe (Boss Stage) com maior recompensa de XP.

---

### User Story 2 - Minigame Adaptativo de Memória de Trabalho (Flash Matrix) (Priority: P1)
**Como** praticante de treino mental,  
**Quero** jogar um desafio de retenção visual onde padrões iluminam brevemente em uma grade,  
**Para que** eu exercite a velocidade de absorção e reprodução da memória fotográfica.

- **Why this priority:** É o minigame principal que entrega o valor de treino cognitivo e concede XP.
- **Independent Test:** Iniciar o minigame, memorizar os blocos acesos durante o tempo de exibição, tocar nos blocos corretos e receber a pontuação e XP.
- **Acceptance Scenarios:**
  1. **Given** o início do jogo no nível 1, **When** os blocos piscam por 1.5s, **Then** o jogador toca nos mesmos blocos; ao acertar todos, avança para a próxima rodada com incremento de dificuldade.
  2. **Given** uma rodada ativa, **When** o jogador toca em um bloco incorreto, **Then** perde uma vida/chance e recebe feedback visual de erro imediato.
  3. **Given** o término das rodadas com vitória, **When** a partida encerra, **Then** o progresso do jogador é computado, concedendo XP e atualizando a trilha.

---

### User Story 3 - Limite de 3 Desafios Diários & Contador de Streak (Priority: P2)
**Como** jogador gratuito,  
**Quero** ter 3 desafios cognitivos por dia e ver minha sequência de dias consecutivos jogados (Streak),  
**Para que** eu crie um hábito diário consistente de treino mental.

- **Why this priority:** Mecanismo central de retenção diária e gatilho de conversão para assinatura.
- **Independent Test:** Executar 3 partidas no mesmo dia; na 4ª tentativa, o acesso ao minigame é bloqueado exibindo o modal/tela de assinatura VIP.
- **Acceptance Scenarios:**
  1. **Given** usuário com 3 desafios disponíveis hoje, **When** completa uma partida, **Then** o contador decrementa para 2 restantes.
  2. **Given** usuário com 0 desafios restantes, **When** tenta iniciar nova fase, **Then** o jogo abre o Paywall VIP informando o limite atingido.
  3. **Given** virada de dia (meia-noite), **When** o app é aberto na nova data, **Then** o saldo de desafios é resetado para 3 (ou 10 se VIP) e o Streak é incrementado se o dia anterior foi jogado.

---

### User Story 4 - Ligas Competitivas Semanais (30 Jogadores) (Priority: P2)
**Como** jogador motivado por ranking social,  
**Quero** competir em uma liga semanal com 30 competidores,  
**Para que** eu dispute posições de promoção para a divisão superior.

- **Why this priority:** Gamificação e engajamento competitivo que estimula a realização de treinos adicionais e plano VIP.
- **Independent Test:** Acessar a aba de Ligas, ver os 30 concorrentes com suas pontuações e posições destacadas (Zona de Promoção Top 7 em verde, Zona de Rebaixamento últimos 5 em vermelho).
- **Acceptance Scenarios:**
  1. **Given** o ganho de 50 XP em uma partida, **When** o jogador abre a tela de Liga, **Then** sua pontuação acumulada aumentou em 50 e sua posição sobe no ranking de forma reativa.
  2. **Given** a tabela da liga, **When** o usuário rola a lista, **Then** os 7 primeiros colocados são sinalizados na Zona de Promoção com borda neon verde.

---

### User Story 5 - Assinatura VIP & Monetização (Priority: P3)
**Como** usuário que deseja treinar intensamente,  
**Quero** assinar o plano VIP (10 desafios diários e bônus de 1.5x de XP),  
**Para que** eu evolua mais rápido nas ligas e não fique travado pelo limite de 3 jogos.

- **Why this priority:** Modelo de negócio sustentável do aplicativo.
- **Independent Test:** Ativar o plano VIP de teste na tela de Paywall e validar que o limite sobe para 10/dia e o XP ganho tem multiplicador 1.5x.
- **Acceptance Scenarios:**
  1. **Given** usuário Free que assina VIP, **When** o plano é ativado, **Then** o limite sobe para 10 desafios/dia e o badge VIP aparece no perfil.
  2. **Given** usuário VIP vencendo uma fase de 100 XP base, **When** recebe o cálculo final, **Then** acumula 150 XP (100 * 1.5).

---

## 3. Edge Cases & Constraints
- **Relógio do sistema adulterado pelo usuário:** O app armazena a última data jogada; se a data atual for retroativa, mantém o bloqueio de tentativas consumidas para evitar fraudes.
- **Saída ou fechamento abrupto durante o minigame:** A tentativa diária só é consumida no momento de início do jogo, evitando que o jogador recarregue para tentar indefinidamente sem gastar tentativa.
- **Empate de pontuação de XP na Liga:** Critério de desempate por ordem cronológica (quem atingiu a pontuação primeiro fica na frente).
- **Persistência local rápida (offline-first):** Todo o estado persiste via `SharedPreferences` em JSON limpo e confiável, funcionando sem conexão com internet.

---

## 4. Success Metrics
- 100% de cobertura de testes unitários nas regras críticas de progresso, streak, limite diário e ligas.
- Zero erros de análise no `dart analyze lib`.
- Tempo de carregamento da Home menor que 300ms.
- Código limpo, idiomático, desacoplado e aderente à filosofia Ponytail.
