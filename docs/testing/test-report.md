# Test Report - NutriFit

## Metadata
- **Execution date:** 2026-03-29
- **Repository:** `nutri-fit`
- **Host environment:** local Windows workstation
- **Flutter SDK:** `3.41.6`
- **Target tested:** Android Emulator `NutriFit_API_36`
- **App mode:** `APP_ENV=dev`, `FIREBASE_ENABLED=false`, `FIREBASE_USE_MOCKS=true`

## Commands executed
| Command | Result | Notes |
|---|---|---|
| `flutter build apk --debug --target-platform android-x64 --dart-define=APP_ENV=dev --dart-define=FIREBASE_ENABLED=false --dart-define=FIREBASE_USE_MOCKS=true` | ✅ | APK generated and installed in emulator |
| `flutter analyze` | ✅ | No issues after fixes applied |
| `flutter test` | ✅ | Test suite passing after fix in `workout_calories_test.dart` |
| `adb install -r build/app/outputs/flutter-apk/app-debug.apk` | ✅ | Install successful |
| `adb shell pm clear com.example.nutri_fit` | ✅ | Used to restart from clean auth/onboarding state |
| `adb` screenshots / UI dumps | ✅ / ⚠️ | Functional, but `uiautomator dump` occasionally failed when the emulator became unstable |

## Functional validation summary
| Area | Status | What was validated |
|---|---|---|
| Welcome | ✅ VERIFIED | Welcome screen rendered and routed to login/register |
| Register | ✅ VERIFIED | Account creation flow worked with mock auth |
| Login | ✅ VERIFIED / ⚠️ BUG FOUND | Sign-in screen rendered; route back into the app worked, but one previously onboarded account returned to onboarding again |
| Onboarding | ✅ VERIFIED | Required fields validated, onboarding completed, redirect to home confirmed |
| Home | ✅ VERIFIED | Dashboard rendered after onboarding and after fresh app relaunch |
| Nutrition | ✅ VERIFIED | Water controls, add meal, edit meal, and delete meal were exercised |
| Exercise dashboard | ✅ VERIFIED | Dashboard rendered after locale/layout fixes; no overflow reproduced on the rerun |
| Exercise add/detail/history/delete | ✅ VERIFIED | Validation snackbar, add, detail, history, and delete were completed manually and with widget tests |
| Progress | ✅ VERIFIED | Weight, body metrics, adherence, and trend screen rendered |
| AI Coach | ✅ VERIFIED | Disclaimer, empty state, send message, mock response, and safety reminder rendered |
| Profile | ✅ VERIFIED | Main screen rendered with activity summary |
| Edit health profile | ✅ VERIFIED | Profile saved through UI and returned to profile screen |
| Goals review | ✅ VERIFIED | Empty state without profile and calculated state after saving profile were both verified |
| Settings | ✅ VERIFIED | Sign out button worked and returned to welcome screen |
| Route guards | ⚠️ BUG FOUND | `register -> onboarding -> home` worked, `sign out -> welcome` worked, but `login -> onboarding` happened for an already onboarded user |

## Detailed walkthrough

### 1. Auth and onboarding
- Started from a clean app state using `pm clear`.
- Verified welcome screen, register page, and account creation.
- Completed onboarding and confirmed redirect to `Inicio`.
- Verified required-field validation during onboarding.

### 2. Nutrition
- Opened nutrition dashboard successfully.
- Increased and decreased water using the quick controls.
- Added a meal and observed updated calorie/meal totals.
- Edited the new meal and confirmed the visible change.
- Deleted the added meal and confirmed totals returned to the prior state.

### 3. Exercise
- Reproduced the original locale crash before the fix:
  - `LocaleDataException: Locale data has not been initialized, call initializeDateFormatting(<locale>)`
- Rebuilt after fixing locale initialization in `lib/main.dart`.
- Re-ran `Ejercicios` after the layout and controller lifecycle fixes.
- Verified exercise dashboard now opens normally and the previous overflow is no longer reproducible.
- Verified the add-workout validation snackbar (`Completa nombre y duración válida.`).
- Added a new workout manually, confirmed the daily summary updated, opened workout detail, opened history, reopened detail from history, deleted the workout, and confirmed it disappeared from both dashboard and history.
- During the rerun, the emulator still showed an intermittent `System UI isn't responding` dialog at startup, but once dismissed the NutriFit app continued working and no Flutter crash or app crash-buffer entry was reproduced.

### 4. Progress
- Verified the `Progreso` screen renders:
  - weight card
  - body measurements
  - adherence summary
  - trend chart area

### 5. AI Coach
- Verified the safety disclaimer and mock-backend notice.
- Sent a message and received a mock assistant response plus the extra wellness disclaimer.
- Note: `adb input text` split one typed message (`cena`) into `c` + `ena`; this is an emulator input artifact, not an app parser issue.

### 6. Profile and goals
- Verified profile landing page.
- Opened `Revisar objetivos y cálculo` before saving a profile and confirmed the expected empty state.
- Opened `Editar perfil de salud`, saved a valid profile through the UI, and returned successfully.
- Re-opened `Revisión de objetivos` and confirmed BMI, calories, macros, and guidance were calculated.

### 7. Settings and session flow
- Opened `Ajustes`.
- Used `Cerrar sesión` and confirmed return to welcome.
- Re-entered with a simple mock account to avoid emulator issues with special characters.
- Observed an unexpected redirect back to onboarding for an account that had already completed onboarding.

## Findings

### High priority
1. **Onboarding completion is not reliably restored after login**
   - Severity: High
   - Evidence: after completing onboarding for a mock account, signing out, and signing back in returned the user to `Onboarding inicial` instead of `Inicio`.
   - Suggested investigation:
     - persistence of onboarding completion state
     - mapping between auth user id and onboarding/profile storage
     - route guard restoration on app start and on sign-in

### Medium priority
2. **Android emulator instability limited long QA sequences**
   - Severity: Medium (environmental, not app code)
   - The AVD still showed `System UI isn't responding` after clean boots and has a history of `qemu-system-x86_64.exe` crashes in Windows Event Log / CrashDumps.
   - Even so, the deep rerun of `Ejercicios` completed once the dialog was dismissed.
   - Crash log buffer for the app remained empty when checked.

## Evidence
- Visual evidence is stored in `docs/screenshots/`.
- Committed evidence is intentionally PNG-only.
- XML UI dumps were used during QA but are ignored from Git because they are temporary operator artifacts.

## Key screenshots
- `01-initial.png`
- `02-register.png`
- `03-onboarding.png`
- `04-onboarding-filled.png`
- `06-after-onboarding-attempt.png`
- `07-nutrition.png`
- `09-nutrition-after-add.png`
- `11-nutrition-after-edit.png`
- `12-nutrition-after-delete.png`
- `13-exercise.png`
- `14-exercise-after-fix.png`
- `16-exercise-main.png`
- `18-progress.png`
- `19-ai-coach-empty.png`
- `20-ai-coach-response.png`
- `21-profile.png`
- `22-goals-review.png`
- `24-profile-after-save.png`
- `25-goals-review-calculated.png`
- `26-settings.png`
- `27-after-signout.png`
- `28-login.png`
- `29-login-returns-onboarding.png`
- `30-exercise-history-after-delete.png`
- `31-exercise-layout-fixed.png`

## Overall conclusion
- The project is now buildable locally on Android, `flutter analyze` passes, and `flutter test` passes.
- Most user-facing modules were validated manually in the emulator.
- The main remaining product issue found in runtime QA is the onboarding/session restoration bug after login.
- The `Ejercicios` subflow now has both manual coverage and widget-test coverage for validation, add, detail, history, and delete.
- I did not reproduce a NutriFit app crash inside `Ejercicios` after the fixes; the remaining instability observed in this session points to the emulator/System UI layer rather than to a confirmed Flutter runtime failure in the feature.
