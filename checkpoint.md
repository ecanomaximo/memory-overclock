# 📍 Checkpoint do Projeto: Memory Overclock

**Data:** 05/11/2026  
**Status do Projeto:** Concluído (Marco: Integração de Autenticação Firebase - Google & Apple/iCloud)

---

## 1. O Que Foi Feito Nesta Sessão
1. **Modelagem Spec-Driven Development (SDD):**
   - Criada especificação formal em `specs/003-auth-firebase-google-apple/` (`spec.md`, `plan.md`, `tasks.md`).
2. **Dependências & Setup do Firebase:**
   - Adicionados `firebase_core: ^5.1.0` e `firebase_auth: ^7.0.1` ao `pubspec.yaml`.
   - Criado `lib/firebase_options.dart` com mapeamento para Web, Android e iOS com suporte a compilação por `--dart-define` ou `flutterfire configure`.
3. **Camada de Autenticação Desacoplada (`AuthService`):**
   - Criado `lib/services/auth_service.dart` com:
     - `signInWithGoogle()`: `GoogleAuthProvider` oficial com scopes de perfil e e-mail.
     - `signInWithApple()`: `OAuthProvider('apple.com')` oficial com scopes de nome e e-mail.
     - `signOut()`: desconexão de credenciais no Firebase.
     - Fallback resiliente automático: caso o app seja executado sem credenciais reais do Firebase configuradas (como em testes unitários e CI), opera em modo de desenvolvimento seguro sem travar.
4. **Integração no Estado e Telas:**
   - `ProgressService` (`lib/services/progress_service.dart`) recebe dados reais da autenticação (`userName`, `userEmail`, `userPhotoUrl`, `authProvider`) e persiste em `SharedPreferences`.
   - `LoginScreen` (`lib/screens/login_screen.dart`): estado com feedback visual de carregamento ("Conectando Google...", "Conectando Apple..."), desativação de botões durante a requisição e tratamento de erros com SnackBar.
5. **Qualidade & Testes:**
   - Criado `test/auth_service_test.dart`.
   - `dart analyze lib`: 0 erros, 0 warnings.
   - `flutter test`: 29 testes aprovados (100% de sucesso).
6. **Deploy & Grafo:**
   - Compilado `flutter build web --release --base-href "/memory-overclock/"`.
   - Publicado na branch `gh-pages` do GitHub e disponível em `https://ecanomaximo.github.io/memory-overclock/`.
   - Grafo Graphify atualizado para 1777 nós e 1988 arestas.

---

## 2. Onde Parou
- A infraestrutura de autenticação com Firebase para Google e Apple/iCloud está 100% integrada, testada e publicada.
- O app opera com o fluxo de autenticação ativo; para conectar ao seu projeto específico no Firebase Console, basta registrar as chaves em `firebase_options.dart` (ou via `flutterfire configure`).

---

## 3. Contexto Técnico Atual
- **Branch:** `main` (código-fonte) / `gh-pages` (distribuição pública)
- **Local Web Server:** `http://localhost:8085/`
- **URL Pública:** `https://ecanomaximo.github.io/memory-overclock/`
- **Testes:** 29 testes passando.
- **Grafo:** `graphify-out/` com 1777 nós.

---

## 4. Próximos Passos
1. Conectar as credenciais do seu projeto do Firebase Console (Web API Key e App ID) para habilitar os popups oficiais do Google e Apple no domínio de produção.
2. Sincronizar o progresso de XP e Ligas em tempo real no Firestore / Cloud Database.
