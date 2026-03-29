# Screenshot evidence

This folder stores curated PNG evidence from manual Android QA runs.

## What is committed
- Final PNG screenshots that document meaningful app states and bugs.

## What is not committed
- Temporary UI dump XML files.
- Intermediate operator artifacts that were only used to calculate tap coordinates during emulator QA.

## Current evidence set
- Initial auth/onboarding flow
- Nutrition CRUD flow
- Exercise crash-before-fix, dashboard-after-fix, and deep QA evidence for history/delete/layout
- Progress screen
- AI Coach empty state and response state
- Profile, goals review empty state, profile save, and goals review calculated state
- Settings sign-out state
- Login screen and post-login onboarding regression evidence

## Notes
- XML UI dumps are ignored through `.gitignore` with `docs/screenshots/*.xml`.
- Emulator screenshots were captured with `adb shell screencap -p` plus `adb pull` to avoid PNG corruption on Windows shell redirection.
- Latest exercise QA evidence includes:
  - `30-exercise-history-after-delete.png`
  - `31-exercise-layout-fixed.png`
