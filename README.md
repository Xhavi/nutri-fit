# NutriFit

Mobile app (Flutter/Dart) for nutrition, exercise, progress tracking, and AI wellness coaching.

> **Safety boundary:** NutriFit is a wellness product and must not be positioned as medical diagnosis or treatment.

## Tech stack
- Flutter + Dart (null-safe)
- Feature-first architecture
- Firebase-ready app bootstrap with mock-friendly local mode
- Firebase Functions (TypeScript) for AI/backend orchestration

## Quick start

```bash
flutter pub get
flutter run \
  --dart-define=APP_ENV=dev \
  --dart-define=FIREBASE_ENABLED=false \
  --dart-define=FIREBASE_USE_MOCKS=true
```

## Quality checks

```bash
flutter analyze
flutter test
```

Backend/functions basic validation:

```bash
cd functions
npm ci
npm run build
```

## CI
GitHub Actions runs:
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- Functions basic validation (`npm ci` + `npm run build`)

Workflow file: `.github/workflows/ci.yml`.

## Documentation index
- Local setup: `docs/setup/local-development.md`
- Environment flags: `docs/setup/environments.md`
- Firebase setup: `docs/setup/firebase.md`
- Architecture overview: `docs/architecture/overview.md`
- Architecture guide: `docs/architecture/guide.md`
- Contribution guide: `CONTRIBUTING.md`
- Product scope: `docs/product/scope.md`
- Product vision: `docs/product/vision.md`
- Roadmap: `docs/roadmap.md`
- AI architecture: `docs/ai/architecture.md`
- AI prompt strategy: `docs/ai/prompt-strategy.md`
- AI safety rules: `docs/ai/safety-rules.md`

## Repository layout
```text
nutri-fit/
  .github/workflows/
  docs/
  functions/
  lib/
  test/
  README.md
  CONTRIBUTING.md
```
