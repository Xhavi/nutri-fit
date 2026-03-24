# NutriFit

Mobile app (Flutter/Dart) for nutrition, exercise, and AI wellness coaching.

## Project vision
NutriFit helps people build sustainable healthy habits by unifying food tracking, exercise tracking, progress visibility, and conversational AI coaching in a single experience.

> Important: NutriFit is a wellness product and **must not** be positioned as medical diagnosis or treatment.

## Core stack
- **Frontend:** Flutter (Dart)
- **Architecture approach:** Feature-first, modular, clean-code oriented
- **Backend integration:** Firebase-ready core with environment-based configuration

## Local setup

### 1) Install dependencies

```bash
flutter pub get
```

### 2) Run in local mock mode (recommended for first run)

```bash
flutter run \
  --dart-define=APP_ENV=dev \
  --dart-define=FIREBASE_ENABLED=false \
  --dart-define=FIREBASE_USE_MOCKS=true
```

### 3) Quality checks

```bash
flutter analyze
flutter test
```

## Firebase and environments docs

- Firebase setup guide: `docs/setup/firebase.md`
- Environment configuration guide: `docs/setup/environments.md`

## Expected repository structure
```text
nutri-fit/
  AGENTS.md
  README.md
  docs/
    architecture/
      overview.md
    product/
      scope.md
      vision.md
    setup/
      environments.md
      firebase.md
    roadmap.md
  lib/
    core/
    features/
    shared/
```

## Current status
The app includes a Firebase-ready bootstrap, environment separation, and mock adapters for Auth/Firestore/Cloud Functions while full authentication flows are still pending.
