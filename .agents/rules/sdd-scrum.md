# Regra: Spec-Driven Development (SDD) & Scrum Task Breakdown

## 1. Princípios de SDD
- Nenhuma feature ou refatoração estrutural deve ser iniciada sem especificação e planejamento formal usando os templates do Spec Kit (`.specify/`).
- Siga a ordem canônica:
  1. `/speckit-specify` - Especificar requisitos, User Stories e critérios de aceite mensuráveis.
  2. `/speckit-plan` - Definir arquitetura técnica, modelo de dados e dependências.
  3. `/speckit-tasks` - Quebrar em tarefas granulares estilo Scrum.
  4. `/speckit-implement` - Implementar tarefa por tarefa com testes e validações.
  5. `/speckit-converge` - Auditar código contra a especificação original.

## 2. Fatiamento Scrum & Otimização de Tokens
- Cada tarefa gerada deve ser autocontida, atômica e com escopo reduzido.
- Evite tarefas genéricas como "implementar tudo de UI".
- Divida em fatias verticais finas (ex: "Criar modelo de estado de fase", "Construir widget individual do nó do mapa", "Adicionar persistência SharedPreferences do streak").
- Isso economiza tokens de saída do modelo, reduz risco de erros e permite depuração rápida e precisa.
