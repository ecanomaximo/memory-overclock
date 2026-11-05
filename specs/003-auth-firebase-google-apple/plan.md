# Implementation Plan: Autenticação Real com Firebase (Google & Apple/iCloud)

**Branch**: `main` | **Date**: 2026-11-05 | **Spec**: [specs/003-auth-firebase-google-apple/spec.md](file:///c:/Users/emaxi/OneDrive/Área%20de%20Trabalho/claude/memory/specs/003-auth-firebase-google-apple/spec.md)

---

## 1. Sumário Executivo
Implementação de camada desacoplada de autenticação com Firebase (`AuthService`) dando suporte nativo a **Google Sign-In** e **Sign in with Apple / iCloud**.  
A solução adota um padrão de injeção limpo que permite rodar tanto com o backend real do Firebase quanto em modo standalone/fallback para testes locais e desenvolvimento rápido.

---

## 2. Decisões Arquiteturais & Ponytail Check

| Princípio | Decisão Técnica | Benefício Ponytail |
|---|---|---|
| **Resiliência & Zero Bloat** | `AuthService` encapsula a lógica do `FirebaseAuth` com tratamento seguro de exceções de plataforma. | Evita acoplamento direto dos widgets da interface aos SDKs do Firebase. |
| **Fallback Seguro para Testes** | Se o Firebase não estiver inicializado com chaves reais (ex: em testes de widget ou offline), o `AuthService` opera em modo simulado sem falhar o build ou os testes. | Zero quebra na suite de 24 testes existentes. |
| **Sincronização de Perfil** | `ProgressService` recebe os dados normalizados (`displayName`, `email`, `photoURL`, `providerId`) e atualiza o `UserProgress`. | Código enxuto, sem duplicação de estado. |

---

## 3. Estrutura de Arquivos Planejada

```text
lib/
├── firebase_options.dart      # Configuração dos identificadores do Firebase (Web, iOS, Android)
├── services/
│   ├── auth_service.dart      # Wrapper desacoplado do Firebase Auth (Google & Apple)
│   └── progress_service.dart  # Integração do login real e sincronização do UserProgress
└── screens/
    └── login_screen.dart      # Feedback de loading e chamada assíncrona ao AuthService
test/
└── auth_service_test.dart     # Teste de unidade do serviço de autenticação
```
