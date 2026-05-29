---
description: "Task list template for feature implementation"
---

# Tasks: MiniProntuário Odontológico MVP

**Input**: Design documents from `/specs/001-miniprontuario-mvp/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Unit tests for logic classes and widget tests for key UI flows MUST be implemented per the constitution.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Mobile app**: Flutter structure under `lib/` and `test/`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Create project structure per implementation plan in `lib/`
- [x] T002 Initialize Flutter project with flutter_riverpod, sqflite_sqlcipher, go_router, flutter_secure_storage
- [x] T003 [P] Configure linting and formatting tools in `analysis_options.yaml`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 Setup GoRouter routing structure in `lib/core/router/app_router.dart`
- [x] T005 [P] Setup secure storage service in `lib/core/utils/secure_storage_service.dart`
- [x] T006 [P] Setup database connection (sqflite_sqlcipher) and migrations in `lib/core/database/database_helper.dart`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Professional Registration and Authentication (Priority: P1) 🎯 MVP

**Goal**: A dentist needs to create a professional account and log in so that their clinical data remains secure and isolated from other users.

**Independent Test**: Can be fully tested by creating a new account, logging out, and successfully logging back in with the created credentials. The session must persist locally.

### Tests for User Story 1

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T007 [P] [US1] Create unit tests for Auth service in `test/features/auth/auth_service_test.dart`

### Implementation for User Story 1

- [x] T008 [P] [US1] Create Dentist model in `lib/features/auth/domain/dentist.dart`
- [x] T009 [US1] Create Auth Repository in `lib/features/auth/data/auth_repository.dart`
- [x] T010 [US1] Create Auth Service in `lib/features/auth/domain/auth_service.dart`
- [x] T011 [US1] Create Login Screen in `lib/features/auth/presentation/login_screen.dart`
- [x] T012 [US1] Create Registration Screen in `lib/features/auth/presentation/registration_screen.dart`
- [x] T013 [US1] Create Auth Riverpod providers in `lib/features/auth/presentation/auth_providers.dart`

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Patient Management (Priority: P1)

**Goal**: A dentist needs to register, view, edit, and delete patients to maintain an organized client base.

**Independent Test**: Can be fully tested by creating a patient, viewing their details, editing their clinical observations, and deleting the record.

### Tests for User Story 2

- [x] T014 [P] [US2] Create unit tests for Patient service in `test/features/patient/patient_service_test.dart`

### Implementation for User Story 2

- [x] T015 [P] [US2] Create Patient model in `lib/features/patient/domain/patient.dart`
- [x] T016 [US2] Create Patient Repository in `lib/features/patient/data/patient_repository.dart`
- [x] T017 [US2] Create Patient Service in `lib/features/patient/domain/patient_service.dart`
- [x] T018 [US2] Create Patient List Screen in `lib/features/patient/presentation/patient_list_screen.dart`
- [x] T019 [US2] Create Patient Form Screen in `lib/features/patient/presentation/patient_form_screen.dart`
- [x] T020 [US2] Create Patient Detail Screen in `lib/features/patient/presentation/patient_detail_screen.dart`
- [x] T021 [US2] Create Patient Riverpod providers in `lib/features/patient/presentation/patient_providers.dart`

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Procedure Registration and History (Priority: P2)

**Goal**: A dentist needs to record dental procedures for a selected patient to track their treatment history over time.

**Independent Test**: Can be fully tested by selecting a patient, adding a new procedure (e.g., Dental cleaning), and verifying it appears correctly in the patient's chronological history.

### Tests for User Story 3

- [x] T022 [P] [US3] Create unit tests for Procedure service in `test/features/procedure/procedure_service_test.dart`

### Implementation for User Story 3

- [x] T023 [P] [US3] Create Procedure model in `lib/features/procedure/domain/procedure.dart`
- [x] T024 [US3] Create Procedure Repository in `lib/features/procedure/data/procedure_repository.dart`
- [x] T025 [US3] Create Procedure Service in `lib/features/procedure/domain/procedure_service.dart`
- [x] T026 [US3] Create Procedure Form Screen in `lib/features/procedure/presentation/procedure_form_screen.dart`
- [x] T027 [US3] Create Procedure Timeline Widget in `lib/features/procedure/presentation/procedure_timeline_widget.dart`
- [x] T028 [US3] Create Procedure Riverpod providers in `lib/features/procedure/presentation/procedure_providers.dart`

**Checkpoint**: All user stories should now be independently functional

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T029 [P] Documentation updates in `README.md`
- [x] T030 Code cleanup and dart format

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 3 (P2)**: Can start after Foundational (Phase 2) - May integrate with US2 but should be independently testable

### Within Each User Story

- Tests (if included) MUST be written and FAIL before implementation
- Models before services
- Services before endpoints/screens
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all models for User Story 1 together:
Task: "Create Dentist model in lib/features/auth/domain/dentist.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently
