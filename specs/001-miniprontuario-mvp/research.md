# Phase 0: Research & Technical Decisions

## 1. State Management
- **Decision**: `flutter_riverpod`
- **Rationale**: Modern, safe by default, and natively supports dependency injection which aligns well with the Clean Architecture requirement from the Constitution. It provides separation of state from UI effectively.
- **Alternatives considered**: `provider` (older, less safe), `bloc` (more boilerplate, might be overkill for an MVP).

## 2. Local Database & Encryption
- **Decision**: `sqflite_sqlcipher`
- **Rationale**: Implements SQLite with 256-bit AES encryption at rest. Highly standard for Flutter apps handling sensitive data. Fulfills the offline-first and security requirements perfectly.
- **Alternatives considered**: `hive` (NoSQL, hard to manage relational data like procedures linked to patients), `isar` (great but heavier and SQL is universally understood).

## 3. Navigation
- **Decision**: `go_router`
- **Rationale**: Declarative routing is officially recommended by the Flutter team. Handles deep linking and nested routes easily.
- **Alternatives considered**: Standard `Navigator 2.0` (too complex manually), `auto_route` (relies heavily on code generation).

## 4. Secure Session Storage
- **Decision**: `flutter_secure_storage`
- **Rationale**: Safely stores the encryption key for the SQLCipher database and the active session identifier. Uses Keychain on iOS and EncryptedSharedPreferences on Android.
- **Alternatives considered**: `shared_preferences` (not secure, data is stored in plain text).
