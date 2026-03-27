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

## AI Coach backend (Firebase Functions)

Server-side foundation is under `functions/` using TypeScript + Firebase Cloud Functions.

### Local backend setup

```bash
cd functions
npm install
npm run build
```

### Environment and secrets

The mobile app must never include the OpenAI API key. Configure it only on backend:

```bash
firebase functions:secrets:set OPENAI_API_KEY
firebase functions:params:set AI_COACH_PROVIDER=openai
firebase functions:params:set OPENAI_MODEL=gpt-4.1-mini
```

For local/dev without credentials, keep mock mode:

```bash
firebase functions:params:set AI_COACH_PROVIDER=mock
```

### Deploy

```bash
firebase deploy --only functions
```

## Firebase and environments docs

- Firebase setup guide: `docs/setup/firebase.md`
- Environment configuration guide: `docs/setup/environments.md`
- AI backend architecture: `docs/ai/architecture.md`
- AI prompt strategy: `docs/ai/prompt-strategy.md`
- AI safety rules: `docs/ai/safety-rules.md`

## Expected repository structure
```text
nutri-fit/
  AGENTS.md
  README.md
  docs/
    architecture/
      overview.md
    ai/
      architecture.md
      prompt-strategy.md
      safety-rules.md
    product/
      scope.md
      vision.md
    setup/
      environments.md
      firebase.md
    roadmap.md
  functions/
    src/
  lib/
    core/
    features/
    shared/
```

## Current status
The app includes a Firebase-ready bootstrap, environment separation, and mock adapters for Auth/Firestore/Cloud Functions while full authentication flows are still pending.
