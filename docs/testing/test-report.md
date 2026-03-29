# Test Report — NutriFit

## Metadata
- **Execution date (UTC):** 2026-03-29
- **Repository:** `nutri-fit`
- **Requested validation scope:** technical checks + manual functional validation + screenshot evidence

## Environment used
- Host: Linux container (`x86_64`)
- Flutter SDK: **not available in this environment** (`flutter: command not found`)
- Dart SDK: **not available in this environment** (`dart` not found)
- Browser automation tool in this execution environment: **not available**

## Commands requested and execution result
| Command | Result | Notes |
|---|---|---|
| `flutter pub get` | ❌ Not executed successfully | `flutter` binary is not installed in container |
| `flutter analyze` | ❌ Not executed successfully | `flutter` binary is not installed in container |
| `flutter test` | ❌ Not executed successfully | `flutter` binary is not installed in container |
| `flutter run -d chrome` | ❌ Not executed successfully | Cannot run app without Flutter SDK/browser runtime |

## Functional inventory identified for validation
Based on navigation/routing and feature pages present in source code:

1. Splash screen
2. Welcome screen
3. Login flow
4. Registration flow
5. Onboarding flow
6. Home dashboard
7. Nutrition module
   - Daily summary
   - Water tracker
   - Meal list
   - Add/Edit meal flow
8. Exercise module
   - Exercise dashboard
   - Add workout
   - Workout detail
   - Exercise history
9. Progress module
10. AI Coach chat module
11. Profile module
   - Profile view
   - Edit health profile
   - Goals review
12. Settings module
13. Session-based route guards/redirects (initializing, unauthenticated, needs onboarding, authenticated)

## Manual functional validation results
> Due to missing Flutter SDK/runtime in the environment, **all runtime/UI validations are marked as `NO VERIFICADA`**.

| # | Functionality | Steps attempted | Result | Status | Observations |
|---|---|---|---|---|---|
| 1 | Splash | Attempted to launch app (`flutter run`) | Could not start app | NO VERIFICADA | Missing Flutter binary |
| 2 | Welcome | Same as above | Could not start app | NO VERIFICADA | Requires runnable app session |
| 3 | Login | Same as above | Could not start app | NO VERIFICADA | Requires runnable app session |
| 4 | Register | Same as above | Could not start app | NO VERIFICADA | Requires runnable app session |
| 5 | Onboarding | Same as above | Could not start app | NO VERIFICADA | Requires runnable app session |
| 6 | Home | Same as above | Could not start app | NO VERIFICADA | Requires runnable app session |
| 7 | Nutrition | Same as above | Could not start app | NO VERIFICADA | Requires runnable app session |
| 8 | Exercise | Same as above | Could not start app | NO VERIFICADA | Requires runnable app session |
| 9 | Progress | Same as above | Could not start app | NO VERIFICADA | Requires runnable app session |
| 10 | AI Coach | Same as above | Could not start app | NO VERIFICADA | Requires runnable app session (+ backend/mocks) |
| 11 | Profile | Same as above | Could not start app | NO VERIFICADA | Requires runnable app session |
| 12 | Settings | Same as above | Could not start app | NO VERIFICADA | Requires runnable app session |
| 13 | Route guards | Attempted via app launch and navigation | Could not validate | NO VERIFICADA | Requires runnable app session |

## Screenshot evidence
- Intended output folder: `docs/screenshots/`
- Result in this run: **no screenshots generated** (app could not be executed in this environment).

## Bugs found
- No product/runtime bugs could be verified because execution was blocked at environment level.
- Environment blocker identified:
  - Missing Flutter SDK installation in PATH.

## Environment limitations and what is needed to complete validation
To fully execute requested validation (technical + functional + screenshots), the following is required:

1. Install Flutter SDK and ensure `flutter` is available in PATH.
2. Ensure at least one runnable target:
   - Chrome/Web (`flutter config --enable-web` + Chrome), or
   - Android emulator, or
   - iOS simulator (macOS only).
3. Run:
   - `flutter pub get`
   - `flutter analyze`
   - `flutter test`
4. Launch app with environment flags (example from README):
   - `flutter run --dart-define=APP_ENV=dev --dart-define=FIREBASE_ENABLED=false --dart-define=FIREBASE_USE_MOCKS=true`
5. Re-run manual functional checklist and collect screenshots in `docs/screenshots/`.
