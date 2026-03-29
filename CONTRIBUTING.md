# Contributing to NutriFit

Thanks for contributing to NutriFit 💚

## Branch and commit conventions
- Create feature branches from `main` using names like `feature/<ticket>-<short-description>`.
- Keep commits focused and reviewable.
- Commit message style recommendation:
  - `feat: ...`
  - `fix: ...`
  - `chore: ...`
  - `docs: ...`
  - `test: ...`

## Local development workflow
1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Run static analysis:
   ```bash
   flutter analyze
   ```
3. Run tests:
   ```bash
   flutter test
   ```
4. Optional backend validation:
   ```bash
   cd functions
   npm ci
   npm run build
   ```

## Pull request checklist
- [ ] I ran `flutter analyze` and fixed warnings/errors.
- [ ] I ran `flutter test` and relevant tests pass.
- [ ] I added/updated documentation for behavior changes.
- [ ] I did not add secrets to source code.
- [ ] I kept AI/wellness language non-clinical.

## Architecture and boundaries
- Follow feature-first organization and keep clear module boundaries.
- Prefer testable and null-safe Dart code.
- NutriFit provides wellness guidance only, never diagnosis or medical treatment.
