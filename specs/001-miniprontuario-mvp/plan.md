# Implementation Plan: MiniProntuário Odontológico MVP

**Branch**: `001-miniprontuario-mvp` | **Date**: 2026-05-29 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-miniprontuario-mvp/spec.md`

## Summary

Implement a lightweight, offline-first dental patient management Flutter application. The MVP includes professional authentication, patient CRUD, and procedure history tracking, all backed by an encrypted local SQLite database (SQLCipher) to ensure patient data privacy.

## Technical Context

**Language/Version**: Dart 3.x, Flutter SDK 3.x

**Primary Dependencies**: flutter_riverpod (state management), sqflite_sqlcipher (database), go_router (navigation), flutter_secure_storage (session management).

**Storage**: Local Encrypted SQLite (SQLCipher) for relational data, Secure Storage for session keys.

**Testing**: flutter_test (Unit and Widget tests).

**Target Platform**: Mobile (Android/iOS).

**Project Type**: mobile-app

**Performance Goals**: Instant visual response for patient search (<200ms).

**Constraints**: Completely offline, single-device usage, strict local data isolation and security.

**Scale/Scope**: MVP scope (Authentication, Patient CRUD, Procedures).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Clean Architecture & State Separation**: Will use Riverpod with layered architecture (Presentation, Domain, Data).
- **SOLID Principles**: Repositories will implement interfaces. Services will encapsulate business logic.
- **Database & Persistence**: Using `sqflite_sqlcipher`. Direct SQL execution in UI is prohibited; will be handled in Data layer.
- **Security & Secret Management**: Encrypted SQLite used. Passwords hashed locally (or relying on encrypted DB).
- **Testing**: Unit and widget tests will be added.

## Project Structure

### Documentation (this feature)

```text
specs/001-miniprontuario-mvp/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── database/
│   ├── router/
│   ├── theme/
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── patient/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── procedure/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart

test/
├── features/
│   ├── auth/
│   ├── patient/
│   └── procedure/
└── core/
```

**Structure Decision**: Feature-first architecture matching the Constitution's Clean Architecture and separation of concerns requirement.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | N/A | N/A |
