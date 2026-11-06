# Feature Specification: 004-onboarding-cognitive-survey

**Feature Branch**: `004-onboarding-cognitive-survey`  
**Created**: 2026-11-05  
**Status**: Approved  
**Input**: User request: "fazer agora um questionário inicial quando o cara abrir o aplicativo a primeira vez, só a primeira vez dele, quando ele vai fazer o cadastro dele, o login pelo Google ou pelo iCloud... questionário de acordo com o que ele sente... ansiedade... estudo do que geralmente tem dentro desses aplicativos de questionários e colocar dentro desse também... extração de formulário para saber a porcentagem depois para fazer um estudo"

---

## 1. Visão Geral & Estudo Neurocognitivo (Benchmarks)
Aplicativos líderes de treino cerebral e saúde mental (como **Impulse**, **Lumosity**, **Elevate** e **Calm**) realizam uma anamnese inicial focada na identificação de "gatilhos emocionais e cognitivos" que levaram o usuário a buscar a solução.
O objetivo primordial do questionário é:
1. **Engajamento & Intenção:** Identificar o motivador primário (ex: Ansiedade, Foco no Trabalho, Falhas de Memória, Prevenção do Envelhecimento Mental).
2. **Diagnóstico do Estado Mental:** Capturar os sintomas mais frequentes (ex: Brain Rot por telas, névoa mental pós-almoço, insônia por pensamentos acelerados).
3. **Calibração de Ritmo:** Conhecer a disponibilidade diária de treino (3 a 5 min vs 10+ min).
4. **Extração de Dados Estatísticos:** Permitir ao administrador e pesquisador analisar percentuais de distribuição das dores e perfil da base de usuários para estudos quantitativos.

---

## 2. User Scenarios & Testing (Scrum Slices)

### User Story 1 - Questionário Inicial de 1º Acesso (Priority: P1)
**Como** novo usuário que acabou de autenticar com Google, Apple ou Entrar como Convidado pela primeira vez,  
**Quero** responder a um questionário rápido, interativo e acolhedor sobre minhas sensações, ansiedade e foco,  
**Para que** o aplicativo entenda o que sinto e personalize minha trilha e metas iniciais.

**Why this priority**: É a primeira experiência do usuário logo após o login e condiciona a retenção e relevância do app.

**Independent Test**: Simular login de novo usuário (`hasCompletedOnboarding: false`). Verificar que a tela do questionário abre automaticamente com 4 passos claros e não exibe o Dashboard até que o questionário seja concluído.

**Acceptance Scenarios**:
1. **Given** um usuário recém-autenticado com `hasCompletedOnboarding == false`,  
   **When** o aplicativo carrega,  
   **Then** o fluxo de telas direciona para `OnboardingSurveyScreen`.
2. **Given** o usuário no questionário,  
   **When** ele seleciona opções para cada uma das perguntas (Motivo principal, Sintomas frequentes, Nível de ansiedade/foco e Tempo disponível),  
   **Then** a barra de progresso avança suavemente e habilita o botão "Próximo".
3. **Given** a última pergunta respondida,  
   **When** o usuário clica em "Gerar Meu Perfil Mental",  
   **Then** o aplicativo exibe breve tela de diagnóstico ("Overclock Calibrado: Foco em Redução de Ansiedade e Memória de Trabalho") e avança para a Trilha/Dashboard com `hasCompletedOnboarding = true`.

---

### User Story 2 - Não Repetição em Acessos Futuros (Priority: P1)
**Como** usuário que já concluiu o questionário inicial,  
**Quero** entrar direto no Painel/Trilha nas sessões seguintes,  
**Para que** não precise responder as mesmas perguntas novamente.

**Why this priority**: Evita fricção desnecessária em usuários recorrentes.

**Independent Test**: Carregar o app com `hasCompletedOnboarding: true` e verificar que o questionário é pulado imediatamente para o `DashboardScreen`.

**Acceptance Scenarios**:
1. **Given** um usuário com `hasCompletedOnboarding == true`,  
   **When** o app inicializa,  
   **Then** abre imediatamente o `DashboardScreen`.

---

### User Story 3 - Persistência das Respostas & Diagnóstico no Perfil (Priority: P2)
**Como** usuário cadastrado,  
**Quero** ver no meu Painel de Perfil um resumo do meu "Perfil Cognitivo Inicial" derivado das minhas respostas,  
**Para que** eu acompanhe a evolução do meu objetivo ao longo dos dias.

**Why this priority**: Dá sentido imediato ao formulário respondido pelo usuário.

**Independent Test**: Responder o questionário com "Reduzir Ansiedade & Sobrecarga" e verificar que no `ProfileScreen` aparece o card "Objetivo Calibrado: Alívio de Ansiedade & Clareza Mental".

**Acceptance Scenarios**:
1. **Given** respostas salvas de onboarding no `UserProgress`,  
   **When** o usuário acessa a aba `Perfil`,  
   **Then** visualiza o card com seu objetivo primário e foco neurológico selecionado.

---

### User Story 4 - Módulo de Extração Analítica de Dados (Porcentagens para Estudo) (Priority: P2)
**Como** administrador / pesquisador do projeto,  
**Quero** visualizar a porcentagem consolidada e distribuição de respostas de todos os formulários coletados,  
**Para que** eu possa conduzir estudos científicos, validações de mercado e entender a prevalência de ansiedade vs foco na base.

**Why this priority**: Requisito explícito do usuário ("quero saber a porcentagem depois para poder fazer um estudo").

**Independent Test**: Abrir o visualizador analítico (via Dev Sheet / Painel de Pesquisa) e constatar o cálculo automático das porcentagens de cada categoria (ex: 60% Ansiedade, 25% Foco, 15% Memória) com botão de exportação em JSON estruturado para pesquisa.

**Acceptance Scenarios**:
1. **Given** registros de formulários no sistema (locais e sincronizados),  
   **When** o menu de auditoria / estudo analítico é aberto,  
   **Then** uma tela dedicada exibe as porcentagens de cada resposta em barras visuais e permite exportar o relatório bruto para estudo.

---

## 3. Requisitos Funcionais (FR)

- **FR-001**: O sistema DEVE persistir a flag booleana `hasCompletedOnboarding` e o objeto estruturado `OnboardingSurveyData` dentro de `UserProgress`.
- **FR-002**: O questionário DEVE conter 4 etapas fundamentais baseadas em neurociência cognitiva:
  - **Etapa 1 (Motivação Central):** "Qual o seu principal objetivo com o Memory Overclock?" (Ansiedade & Sobrecarga, Foco no Trabalho/Estudos, Falhas de Memória, Raciocínio Rápido, Longevidade Mental).
  - **Etapa 2 (Sintomatologia Frequente):** "O que você tem sentido com mais intensidade ultimamente?" (Mente acelerada/ansiosa à noite, Névoa mental pós-almoço, Distração crônica com celular, Esquecimento de nomes e compromissos).
  - **Etapa 3 (Autoavaliação de Ansiedade / Estresse):** "Em qual frequência a ansiedade ou sobrecarga atrapalha sua produtividade?" (Raramente, Às vezes, Quase todos os dias, O tempo todo).
  - **Etapa 4 (Disponibilidade Diária):** "Quanto tempo pretende dedicar por dia?" (3 a 5 min - Micro-doses, 5 a 10 min - Recomendado, 15+ min - Modo Intenso).
- **FR-003**: O layout do questionário DEVE ser centralizado (`maxWidth: 540`), responsivo, e apresentar barra de progresso linear e feedback visual claro no clique.
- **FR-004**: Ao finalizar, o sistema DEVE computar a categoria primária de foco (ex: `Ansiedade & Equilíbrio Emocional`, `Hiperfoco & Atenção`, `Memória Operacional`) e persistir no perfil.
- **FR-005**: O sistema DEVE fornecer um serviço analítico (`SurveyAnalyticsService`) capaz de calcular percentuais de agregação para qualquer conjunto de respostas.
- **FR-006**: O sistema DEVE disponibilizar uma interface modal de visualização dos dados consolidados (com porcentagens, contadores e botão de exportação JSON).
- **FR-007**: Toda a experiência DEVE manter o tema escuro futurista (Ciano, Verde Bio, Âmbar Solar e Magenta Alerta) consistente com o restante da aplicação.
- **FR-008**: 100% da lógica e telas devem possuir cobertura de testes automatizados (`flutter test`).

---

## 4. Edge Cases
- **Fechamento do navegador durante o questionário:** Como `hasCompletedOnboarding` ainda será `false`, o app reabrirá no questionário na próxima sessão sem corromper o progresso.
- **Usuários antigos pré-existentes:** Para não quebrar usuários que já estão em níveis avançados, se `currentLevel > 1` ou `weeklyXp > 0`, o sistema assume `hasCompletedOnboarding: true` retrocompatível com opção de refazer o teste pelo perfil.
