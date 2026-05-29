# Quickstart

## Local Development Setup

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Generate Code (if applicable)**
   If using code generation (like Freezed or Riverpod generator), run:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

## Architecture Notes
- The app uses `flutter_riverpod` for state management.
- Data is persisted locally using `sqflite_sqlcipher`.
- Follow the `lib/features/` folder structure. Each feature contains `data`, `domain`, and `presentation` layers.
