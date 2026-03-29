# Architecture guide

## Principles
- Feature-first structure.
- Explicit boundaries between presentation, domain, and data layers.
- Null-safe and testable Dart code.
- Clear wellness-only language in AI features (non-medical positioning).

## Repository map
- `lib/app/`: app shell, theme, router.
- `lib/core/`: shared technical infrastructure (config, services, bootstrap, utils).
- `lib/features/<feature>/`:
  - `presentation/`: pages, controllers, widgets.
  - `domain/`: entities, enums, contracts/use-cases.
  - `data/`: repositories, adapters, API clients.
- `lib/shared/`: reusable UI primitives and cross-feature models.
- `functions/`: serverless AI/backend orchestration.

## State and dependency direction
- Presentation depends on domain abstractions, not concrete data implementations.
- Data layer implements domain contracts.
- Keep adapters/services thin and mappers deterministic.

## Testing strategy
- Domain: unit tests for pure logic.
- Data mappers/repositories: deterministic unit tests with representative input.
- Presentation: selective widget/controller tests for critical UI behavior.

## Quality gates
- `flutter analyze`
- `flutter test`
- Functions TypeScript build in CI (`npm run build`)
