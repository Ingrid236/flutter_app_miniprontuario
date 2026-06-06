# Research & Decisions

## Technical Context Clarifications
- **Language/Version**: Dart / Flutter
- **Primary Dependencies**: sqflite_sqlcipher, shared_preferences (for theme/session), provider/riverpod/bloc (state management)
- **Storage**: SQLite local database (encrypted) and SharedPreferences for settings
- **Testing**: flutter test
- **Target Platform**: Android / iOS
- **Project Type**: Mobile Application
- **Performance Goals**: 60 fps for UI animations, responsive layouts
- **Constraints**: Offline-first standalone app
- **Scale/Scope**: Single professional (Dentist) per device

## Decisions

### 1. Backend Integration Strategy
- **Decision**: Standalone offline-first app using local encrypted SQLite database (Option A)
- **Rationale**: User explicitly selected this option during Clarifications. Allows usage without internet connection and ensures local data isolation.

### 2. CRO Field Formatting and Validation
- **Decision**: Dropdown to select the state (UF) + numeric-only field for the CRO number (Option A)
- **Rationale**: User selected this option. Provides better UX and data consistency.

### 3. Localized Currency Formatting Standard
- **Decision**: Dynamically adapt to the device system locale (Option B)
- **Rationale**: User selected this option. Ensures prices are displayed correctly regardless of region, using intl package.
