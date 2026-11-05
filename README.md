# 🧠 Memory Overclock (Jogo de Memória com Trilha & Ligas)

Jogo mobile em **Flutter** focado em treino de memória de trabalho (anti-brain rot) com progressão no estilo **Duolingo**, mecânica de **3 desafios diários gratuitos**, **assinatura mensal para VIPs (10 desafios/dia)** e **Ligas Semanais ranqueadas com 30 competidores**.

---

## 🎮 O que já está implementado no código:

1. **Trilha estilo Duolingo (`HomeScreen`):**
   - Caminho ondulado com nós interativos de fases.
   - Nós de fases normais e fases de Chefes (a cada 5 níveis).
   - Bloqueio progressivo (fase só abre após vencer a anterior).
   - Status visual: Concluída (Verde Neon), Atual (Ciano Neon pulsante) e Bloqueada (Cinza).

2. **Regra de Negócio: 3 Desafios Diários (`ProgressService`):**
   - O usuário gratuito tem **3 desafios por dia**.
   - Reseta automaticamente à meia-noite (com base no relógio do aparelho).
   - Ao bater o limite de 3 desafios, abre o modal de Assinatura VIP.

3. **Assinatura Mensal VIP (`PaywallScreen`):**
   - Desbloqueia **10 desafios por dia** (ou ilimitado).
   - Bônus de 1.5x no ganho de XP semanal.
   - Botão interativo para ativar/desativar o plano de teste no app.

4. **Ofensiva / Contador de Dias (🔥 Streak):**
   - Registra dias seguidos jogados no topo da tela.
   - Mantém a ofensiva se jogado no dia seguinte; reseta se passar mais de 1 dia sem abrir o app.

5. **Ligas Competitivas Semanais (`LeagueScreen`):**
   - Sala de 30 jogadores simulada com pontuações dinâmicas.
   - Posição do jogador atualizada em tempo real conforme ganha XP.
   - **Top 7:** Linha verde de promoção de liga.
   - **Últimos 5:** Linha vermelha de rebaixamento.

6. **Minigame de Memória Fotográfica Adaptativo (`FlashMatrixGame`):**
   - **Crianças / Nível 1 a 2:** Grade 3x3 com 3 a 4 blocos e tempo calmo (1.8s).
   - **Intermediário / Nível 3 a 5:** Grade 4x4 com 4 a 6 blocos (1.4s).
   - **Avançado / Nível 6+:** Grade 4x4 e 5x5 com velocidade acelerada e reflexos rápidos (800ms).

---

## 🚀 Como Rodar o Projeto

1. Certifique-se de ter o Flutter instalado em seu computador:
   ```bash
   flutter doctor
   ```
2. Instale as dependências:
   ```bash
   flutter pub get
   ```
3. Conecte seu celular Android (via USB com depuração ativada) ou abra um emulador, e rode:
   ```bash
   flutter run
   ```
