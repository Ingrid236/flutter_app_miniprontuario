# Tasks: UI, UX and Functional Refinements

**Input**: Design documents from `/specs/002-ui-ux-refinements/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Update pubspec.yaml to include necessary dependencies (e.g., `intl`, `mask_text_input_formatter` if not present)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [x] T002 Implement SharedPreferences service locator / initialization in `lib/core/utils/`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Theme Auto-detection and Manual Persistence (Priority: P1) 🎯 MVP

**Goal**: App automatically adapts to light/dark system mode and allows manual theme switching that persists upon restart.

**Independent Test**: Verify by toggling system theme settings, confirming the app responds immediately, and verifying that manual selections persist upon restart.

### Implementation for User Story 1

- [x] T003 [P] [US1] Create `AppSettings` model in `lib/core/theme/app_settings.dart`
- [x] T004 [US1] Implement `SettingsRepository` using SharedPreferences in `lib/features/settings/data/settings_repository.dart`
- [x] T005 [US1] Implement `ThemeProvider` or `ThemeController` in `lib/core/theme/theme_provider.dart`
- [x] T006 [US1] Update `lib/main.dart` to consume the theme mode from `ThemeProvider`
- [x] T007 [US1] Add a Theme Toggle switch in the UI (e.g., Settings Screen or Drawer) in `lib/features/settings/presentation/settings_screen.dart`

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Form Input Formatting & Actionable Errors (Priority: P1)

**Goal**: Input masks on fields like CPF, Phone, Dates, and CRO, along with clear and actionable validation error messages.

**Independent Test**: Type values into the Patient form, verify masks format text dynamically, and try entering invalid values to confirm errors explain what happened, why, and how to fix.

### Implementation for User Story 2

- [x] T008 [P] [US2] Create input formatters for CPF and Phone in `lib/core/utils/formatters.dart`
- [x] T009 [P] [US2] Create dynamic currency formatter based on locale in `lib/core/utils/currency_formatter.dart`
- [x] T010 [US2] Update CRO field to use a Dropdown (State/UF) and numeric input in `lib/features/patient/presentation/widgets/patient_form.dart`
- [x] T011 [US2] Apply CPF, Phone, Date formatters to `lib/features/patient/presentation/widgets/patient_form.dart`
- [x] T012 [US2] Apply currency formatter to Procedure cost input in `lib/features/patient/presentation/widgets/procedure_form.dart`
- [x] T013 [US2] Refactor form validation logic to provide actionable error messages (What, Why, How to fix) in `lib/features/patient/presentation/widgets/patient_form.dart` and `procedure_form.dart`

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Patient Data Isolation and Ownership (Priority: P1)

**Goal**: Ensure patients' data and clinical histories are completely isolated from other dentists.

**Independent Test**: Register two distinct accounts, verify that Patients created by Account A are completely hidden and inaccessible via search/list to Account B.

### Implementation for User Story 3

- [x] T014 [US3] Ensure `DentistSession` securely provides `activeDentistId` in `lib/features/auth/data/auth_repository.dart`
- [x] T015 [US3] Update `PatientRepository` SQL queries to filter by `dentistId = activeDentistId` on all Read operations in `lib/features/patient/data/patient_repository.dart`
- [x] T016 [US3] Update `PatientRepository` to automatically set `dentistId` on Patient creation in `lib/features/patient/data/patient_repository.dart`
- [x] T017 [US3] Ensure logout action completely clears local session state and cached patient data in `lib/features/auth/presentation/auth_providers.dart` (or relevant controller)

**Checkpoint**: All P1 user stories should now be independently functional

---

## Phase 6: User Story 4 - Responsive and Overflow-free Layouts (Priority: P2)

**Goal**: All buttons, title bars, and patient cards fit and adjust to screen width down to 320dp without RenderFlex overflows.

**Independent Test**: Load the app on a narrow device emulator and verify that the "Add Procedure" button wraps or fits alongside the history header.

### Implementation for User Story 4

- [x] T018 [US4] Fix RenderFlex horizontal overflow in the `Histórico de Procedimentos` header in `lib/features/patient/presentation/patient_detail_screen.dart` (use Wrap or flexible layout)
- [x] T019 [US4] Ensure Patient list cards avoid text overflow and action icons remain visible in `lib/features/patient/presentation/widgets/patient_list_item.dart`
- [x] T020 [US4] Review dialogs to ensure they adapt to small screens without vertical/horizontal overflow

---

## Phase 7: User Story 5 - Mobile Usability & Accessibility (Priority: P3)

**Goal**: Easily tappable touch targets (48x48 dp), readable text contrast, and full keyboard navigation.

**Independent Test**: Verify touch targets are at least 48x48 dp and that text contrast ratios meet accessibility standards in both Light and Dark modes.

### Implementation for User Story 5

- [x] T021 [US5] Enforce minimum 48x48 touch targets for all action buttons and icon buttons across the app
- [x] T022 [US5] Implement proper `textInputAction` (next/done) and focus nodes in all form fields in `lib/features/patient/presentation/widgets/patient_form.dart`
- [x] T023 [US5] Verify color contrast and adjust `ThemeData` text colors for both Light and Dark themes in `lib/core/theme/app_theme.dart`

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T024 [P] Verify application starts correctly without regression
- [x] T025 Run tests `flutter test` to ensure no broken tests

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion
- **User Stories (Phase 3-7)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **US1, US2, US3, US4, US5**: Can be worked on completely independently in parallel once foundational is complete.

## Implementation Strategy

### MVP First
1. Complete Phase 1 & 2
2. Complete Phase 3 (US1) -> Validate manually

### Incremental Delivery
3. Add User Story 2 (Formatting)
4. Add User Story 3 (Data Isolation)
5. Add User Story 4 (Responsiveness)
6. Add User Story 5 (Accessibility)
