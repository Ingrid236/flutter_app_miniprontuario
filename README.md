# MiniProntuário Odontológico — MVP

MiniProntuário Odontológico is a lightweight, offline-first, and highly secure patient record management system designed for dental professionals and small dental clinics. 

It allows dentists to securely manage their credentials, keep detailed patient files, and log/track clinical procedures over time.

---

## 🚀 Key Features (MVP)

1. **Professional Registration & Authentication**: Secure account creation and session persistence.
2. **Patient Management (CRUD)**: Easily add, view, update, and delete patient records with custom fields for clinical observations (allergies, chronic illnesses, and active medications).
3. **Procedure Tracking**: Register and view dental procedures with tooth selection, cost logs, status tags (Planned/Completed), and chronologically ordered timelines.
4. **Security at Rest**: Relational data is stored locally in an encrypted database using SQLCipher.
5. **Offline-First**: Fully functional without internet connectivity, storing all data securely on the local device.

---

## 🛠️ Technology Stack

- **Framework**: [Flutter SDK 3.x](https://flutter.dev)
- **Language**: [Dart 3.x](https://dart.dev)
- **State Management**: [Riverpod v3 (Notifier/AsyncNotifier APIs)](https://riverpod.dev)
- **Database**: [sqflite_sqlcipher](https://pub.dev/packages/sqflite_sqlcipher) (SQLite with 256-bit AES encryption)
- **Session & Key Storage**: [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) (Keychain on iOS, EncryptedSharedPreferences on Android)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) (Declarative routing with auth redirection guards)
- **Testing**: Native `flutter_test` (Unit and Widget tests)

---

## 📐 Architecture & Principles

The codebase adheres strictly to the **MiniProntuario Constitution** (Clean Architecture + SOLID):
- **Feature-First Organization**: The project is organized by functional features (`auth`, `patient`, `procedure`) inside `lib/features/` to maintain high modularity.
- **Strict Layer Separation**:
  - **Presentation Layer**: Declarative Widgets representing state and dispatching actions. Business logic is strictly isolated from this layer.
  - **Domain Layer**: Models, interfaces, and core business services (`AuthService`, `PatientService`, `ProcedureService`).
  - **Data Layer**: Concrete database access code, migrations, and repositories (`SqliteAuthRepository`, `SqlitePatientRepository`, `SqliteProcedureRepository`).
- **Dependency Inversion**: Services and controllers depend on abstract repository definitions. Concrete SQLite implementations are injected at runtime via Riverpod.
- **TDD (Test-Driven Development)**: Implementation is covered by unit tests validating services and widgets, ensuring code stability and regression-free enhancements.

---

## 📂 Directory Structure

```text
lib/
├── core/
│   ├── database/        # SQLite databases & helpers
│   ├── router/          # GoRouter setups & redirects
│   ├── theme/           # Premium Slate dark theme definitions
│   └── utils/           # Shared secure storage utilities
├── features/
│   ├── auth/            # Dentist account registration & login
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── patient/         # Patient details & CRUD logs
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── procedure/       # Dental treatments & timeline histories
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart            # ProviderScope & MaterialApp.router entrypoint
```

---

## 🏁 Getting Started

### Prerequisites

- Flutter SDK (v3.x or above) installed.
- Physical device or emulator (Android / iOS).

### Installation & Run

1. **Clone the repository** (if not already done).
2. **Fetch all dependencies**:
   ```bash
   flutter pub get
   ```
3. **Execute the test suite** to confirm all unit and widget tests pass:
   ```bash
   flutter test
   ```
4. **Launch the application** on your connected device/simulator:
   ```bash
   flutter run
   ```

---

## 🛡️ Security Details

- On the first application launch, `SecureStorageService` automatically generates a secure, cryptographically random key using `Random.secure()` and encodes it in Base64.
- This key is stored securely in the device's native secure vaults (using `flutter_secure_storage`).
- The database is initialized and accessed using `sqflite_sqlcipher` with this key. Any direct attempt to read the database file from disk without the key results in an unreadable encrypted blob.
- Dentist passwords are saved as cryptographically hashed representations (SHA-256) in the database. Raw passwords are never stored.
