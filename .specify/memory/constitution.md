# Memory Overclock Constitution

## Core Principles

### I. Spec-Driven Development (SDD) & Scrum Task Breakdown
Every functional iteration must be modeled via formal specification (`spec.md`), technical planning (`plan.md`), and granular Scrum tasks (`tasks.md`). Tasks must be sliced into fine vertical units to maximize token efficiency, clarity, and prevent context bloat.

### II. Ponytail Minimalism (Least Code, Maximum Impact)
The best code is the code never written. Solve user needs with the minimum idiomatic Dart/Flutter code. No speculative wrappers, empty abstractions, or "future-proofing". Leverage Flutter's built-in stateful/stateless widgets and existing packages (`shared_preferences`, `google_fonts`, `intl`).

### III. Test-Driven Verification for Core Business Rules
Business rules governing player progression must be covered by automated unit tests:
1. Daily challenge limits (Free: 3/day, VIP: 10+/day) and midnight resets.
2. Daily streak tracking, preservation, and resets.
3. Weekly league XP scoring, ranking sort, promotion (top 7) and relegation (bottom 5).

### IV. Mandatory Checkpoint Traceability
Every session and milestone must maintain and immediately update `checkpoint.md` at the project root with the status, completed tasks, exact stopping point, technical context, and prioritized next steps.

### V. Engaging Cognitive UX (Duolingo-Style)
The visual and interactive standard is a high-contrast dark cyberpunk/neon aesthetic (cyan, purple, neon green, amber) with smooth micro-animations, clear phase unlocking progression, and low latency input response for cognitive training minigames.

## Governance
This constitution governs all feature implementation and refactoring in Memory Overclock. Any PR or major change must verify compliance with SDD, minimalism, and business logic tests.

**Version**: 1.0.0 | **Ratified**: 2026-11-05
