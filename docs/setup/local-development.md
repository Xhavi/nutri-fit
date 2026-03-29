# Local development setup

## Prerequisites
- Flutter SDK (stable channel)
- Dart SDK (bundled with Flutter)
- Node.js 20.x (for `functions/`)
- Firebase CLI (optional for backend deploy/emulation)

## 1) Install app dependencies

```bash
flutter pub get
```

## 2) Run app in local mock mode (recommended)

```bash
flutter run \
  --dart-define=APP_ENV=dev \
  --dart-define=FIREBASE_ENABLED=false \
  --dart-define=FIREBASE_USE_MOCKS=true
```

## 3) Run quality checks

```bash
flutter analyze
flutter test
```

## 4) Backend/functions validation (optional)

```bash
cd functions
npm ci
npm run build
```

## 5) Common issues
- If Flutter commands are not found, verify SDK installation and PATH.
- If Firebase is disabled, use mock services to avoid auth/firestore dependencies.
- Never store OpenAI or Firebase private credentials in app source files.
