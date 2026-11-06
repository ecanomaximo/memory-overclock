# 📍 Checkpoint do Projeto: Memory Overclock

**Data:** 05/11/2026  
**Status do Projeto:** Concluído (Gatilho Automático do Questionário & Botões de Reset/Abertura Imediata)

---

## 1. O Que Foi Feito Nesta Sessão
1. **Ativação Imediata do Questionário para o Usuário:**
   - Ajustada a regra de deserialização do `UserProgress`: todo usuário que ainda não possui `surveyData` gravado é automaticamente direcionado para o questionário no momento em que abrir o aplicativo.
   - Adicionado método `resetOnboarding()` no `ProgressService` para permitir reiniciar a anamnese com um toque.
2. **Novos Atalhos para Ver/Testar o Formulário:**
   - **No Perfil do Usuário:**
     - Botão em destaque ciano: **`Ver / Refazer Formulário`** dentro do card do perfil neurocognitivo.
     - Ícone de prancheta/questionário na barra superior (`AppBar`) do Perfil.
   - **Na Trilha (Menu Dev):**
     - Opção `Reiniciar Questionário (Ver Formulário)`.
3. **Validação & Testes:**
   - `dart analyze lib test`: 0 avisos / 0 erros.
   - `flutter test`: 37/37 testes passando 100%.
   - `flutter build web --release`: compilado e publicado na branch `gh-pages` (commit `dfe9dee`).

---

## 2. Onde Parou
- Build atualizado e disponível no GitHub Pages.

---

## 3. Contexto Técnico Atual
- **Branch:** `main` (código-fonte)
- **Branch de Produção:** `gh-pages` (ativo)
- **Testes:** 37 testes passando (100%).
- **URL Pública:** `https://ecanomaximo.github.io/memory-overclock/`

---

## 4. Próximos Passos
1. Informar o usuário de que o formulário abrirá imediatamente ao recarregar a página, e indicar os botões no Perfil caso deseje refazer quantas vezes quiser.
