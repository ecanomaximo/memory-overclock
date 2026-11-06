# 📍 Checkpoint do Projeto: Memory Overclock

**Data:** 06/11/2026  
**Status do Projeto:** Concluído (Firebase Real Conectado, Remoção de Mocks e Sincronização de Formulário no Cloud Firestore)

---

## 1. O Que Foi Feito Nesta Sessão
1. **Configuração do Firebase Real com Credenciais Web:**
   - Inseridas as credenciais do projeto `memory-overclock-f8259` em [`DefaultFirebaseOptions`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/firebase_options.dart).
   - Login com Google e Apple agora executam diretamente através do SDK oficial do Firebase Authentication.
2. **Eliminação Completa de Dados Simulados (Mocks):**
   - Usuário de teste "Alexandre Silva" e e-mail fictício removidos de [`UserProgress`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/models/user_progress.dart) e [`AuthService`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/services/auth_service.dart).
   - Os 29 bots simulados (`Lucas_Foco`, `Ana_Neuro`, etc.) foram removidos de [`LeagueService`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/services/league_service.dart).
   - Arquivo legado `lib/models/league_model.dart` excluído.
   - [`LeagueScreen`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/screens/league_screen.dart) adaptado para competidores reais com banner explicativo quando a divisão estiver no início da rodada.
3. **Sincronização em Nuvem do Formulário no Cloud Firestore:**
   - Adicionado pacote `cloud_firestore: ^7.1.0`.
   - Criado [`FirestoreService`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/services/firestore_service.dart) para salvar os dados da anamnese cognitiva na coleção `onboarding_surveys`.
   - Conectado ao término do questionário em [`ProgressService.completeOnboarding`](file:///c:/Users/emaxi/OneDrive/Área de Trabalho/claude/memory/lib/services/progress_service.dart).
4. **Validação & Testes:**
   - `dart analyze lib test`: 0 erros / 0 avisos.
   - `flutter test`: 38/38 testes passando (100%).
   - `flutter build web --release`: compilado com sucesso em `build/web`.

---

## 2. Onde Parou
- Todas as alterações implementadas, validadas com testes automatizados e compiladas para deploy.

---

## 3. Contexto Técnico Atual
- **Projeto Firebase:** `memory-overclock-f8259`
- **Coleção Firestore:** `onboarding_surveys`
- **Branch:** `main` (código-fonte), `gh-pages` (produção web)
- **URL Pública:** `https://ecanomaximo.github.io/memory-overclock/`
- **Testes:** 38/38 aprovados.

---

## 4. Próximos Passos
1. No Firebase Console do usuário:
   - Habilitar **Cloud Firestore** em modo de produção/teste (se ainda não clicou em "Criar banco de dados").
   - Em **Authentication > Settings > Domínios autorizados**, certificar-se de ter adicionado `ecanomaximo.github.io`.
   - Em **Authentication > Sign-in method**, confirmar a ativação do Google e da Apple.
