# NutriFit

Mobile app (Flutter/Dart) for nutrition, exercise, and AI wellness coaching.

## Project vision
NutriFit helps people build sustainable healthy habits by unifying food tracking, exercise tracking, progress visibility, and conversational AI coaching in a single experience.

> Important: NutriFit is a wellness product and **must not** be positioned as medical diagnosis or treatment.

## Core stack
- **Frontend:** Flutter (Dart)
- **State management:** Riverpod
- **Routing:** go_router
- **Architecture approach:** Feature-first, modular, clean-code oriented
- **Planned backend:** Serverless services for AI orchestration and data APIs

## Initial modules (MVP-oriented)
- Authentication & user profile
- Nutrition logging (meals, macros, daily summary)
- Exercise logging (sessions, intensity, duration)
- Progress tracking (weight, measurements, streaks, trends)
- AI coach chat (wellness guidance and habit support)

## Current repository structure
```text
nutri-fit/
  AGENTS.md
  README.md
  pubspec.yaml
  analysis_options.yaml
  lib/
    main.dart
    app/
    core/
    shared/
    features/
  test/
  docs/
```

## Getting started
### 1) Prerequisites
- Flutter SDK installed and available in PATH
- A configured device/emulator (Android/iOS)

### 2) Install dependencies
```bash
flutter pub get
```

### 3) Run the app
```bash
flutter run
```

### 4) Quality checks
```bash
flutter analyze
flutter test
```

## Working flow with Codex
1. Define objective and constraints for a small iteration.
2. Ask Codex for a short plan before edits.
3. Implement only the scoped change set.
4. Run checks/tests for impacted areas.
5. Review diff and commit with clear message.
6. Open PR with context, risks, and next step.
