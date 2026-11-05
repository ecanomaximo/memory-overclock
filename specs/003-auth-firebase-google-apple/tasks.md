# Tasks: Autenticação Real com Firebase (Google & Apple/iCloud)

**Input**: Design documents from `specs/003-auth-firebase-google-apple/` (`spec.md` & `plan.md`)  
**Prerequisites**: `spec.md`, `plan.md`  
**Organization**: Decomposição em User Stories Scrum com fatiamento vertical fino para máxima eficiência de tokens.

---

## Sprint 1: Setup & Serviço de Autenticação Desacoplado (US1, US2, US3)
- [x] **T001** [P] [Setup] Adicionar dependências `firebase_core` e `firebase_auth` no `pubspec.yaml`.
- [x] **T002** [US1, US2] Criar `lib/services/auth_service.dart` com métodos `signInWithGoogle()`, `signInWithApple()`, `signOut()` e modo fallback para desenvolvimento/testes.
- [x] **T003** [US1, US2] Criar `lib/firebase_options.dart` para suportar configuração de chaves do Firebase Web e Mobile.
- [x] **T004** [US3] Escrever suite de testes unitários em `test/auth_service_test.dart`.

---

## Sprint 2: Integração no ProgressService e Telas de UI
- [x] **T005** [US1, US2, US3] Atualizar `lib/services/progress_service.dart` para receber os dados reais do `AuthService` e persistir a sessão.
- [x] **T006** [US1, US2] Atualizar `lib/screens/login_screen.dart` com indicador de carregamento (spinner) enquanto o popup de login é processado.
- [x] **T007** [US3] Atualizar `lib/screens/profile_screen.dart` para suportar logout integrado com o `AuthService`.
- [x] **T008** [Setup] Atualizar `lib/main.dart` com a inicialização segura do Firebase.

---

## Sprint 3: Validação, Build Web, Grafo & Versionamento
- [x] **T009** Executar `dart analyze lib` e garantir 0 issues.
- [x] **T010** Executar `flutter test` e garantir 100% dos testes aprovados (29 testes passando).
- [x] **T011** Recompilar web (`flutter build web --release --base-href "/memory-overclock/"`).
- [x] **T012** Publicar build atualizado na branch `gh-pages` e sincronizar `main`.
- [x] **T013** Atualizar grafo AST com `python -m graphify update .`.
- [x] **T014** Atualizar `checkpoint.md` e entregar instrução de configuração ao usuário.
