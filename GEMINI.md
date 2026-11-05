# Memory Overclock - Regras do Projeto & Diretrizes

Este projeto segue rigorosamente as diretrizes globais de engenharia, especificações e rastreabilidade.

## 1. Regra Obrigatória do `checkpoint.md`
- **Arquivo Obrigatório:** Todo ciclo de trabalho neste projeto deve manter e atualizar o arquivo [`checkpoint.md`](./checkpoint.md) na raiz.
- **Rastreabilidade:** Sempre documentar:
  1. O que foi feito.
  2. Onde parou exatamente.
  3. Contexto técnico do estado atual (arquivos, testes, estado de build).
  4. Próximos passos imediatos.
- **Antes de qualquer entrega:** O `checkpoint.md` deve estar atualizado refletindo o progresso.

---

## 2. Spec-Driven Development (SDD) com Spec Kit
- Toda nova funcionalidade, refatoração de tela, modelo de dados ou lógica de negócios deve ser conduzida através do **Spec Kit** localizado em `.specify/`.
- **Comandos do fluxo SDD:**
  - `/speckit-specify` - Especificação da funcionalidade/módulo.
  - `/speckit-plan` - Arquitetura técnica e plano de implementação.
  - `/speckit-tasks` - Quebra Scrum com fatiamento vertical e granularidade econômica de tokens.
  - `/speckit-implement` - Execução orientada a testes e especificações.
  - `/speckit-converge` - Validação final e verificação de critérios de aceite.
- **Formato Scrum:** Tarefas pequenas, isoladas e modulares, priorizando consumo mínimo de tokens e evitando respostas longas e truncadas.

---

## 3. Filosofia Ponytail (Pragmatismo & Simplicidade)
- Menos código é melhor código: use soluções enxutas e idiomáticas de Flutter/Dart.
- Reutilize o que o Flutter e os pacotes já instalados oferecem. Sem sobrecarga de camadas ou classes supérfluas.
- Testes unitários para lógica crítica: cálculo de XP das ligas, limite de 3 desafios/dia, resets de data e streak.

---

## 4. Superpowers & Graphify
- O mapeamento AST do projeto gerado pelo Graphify (`graphify-out/`) deve ser consultado antes de refatorar chamadas e dependências.
- Executar `/graphify update .` sempre que houver mudanças estruturais para manter a base de conhecimento sincronizada.
