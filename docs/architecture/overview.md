# Architecture Overview — NutriFit

## High-level direction
NutriFit will use a modular architecture that separates mobile client concerns from AI/backend orchestration to remain scalable and maintainable.

## Frontend
- **Technology:** Flutter + Dart
- **Style:** Feature-first modules with clear separation of responsibilities
- **Quality goals:** Null-safety, testability, composability, and predictable state handling

## Backend (planned)
- **Approach:** Serverless backend for API endpoints, user data access, and AI orchestration
- **Responsibilities:**
  - Authentication/session validation
  - User data persistence APIs
  - AI coaching prompt orchestration and guardrails
  - Analytics/event ingestion (as needed)

## AI coaching boundary
- AI responses are wellness-oriented guidance.
- No clinical diagnosis/treatment behavior is permitted.

## Future platform integrations
- Android: **Health Connect** (future integration)
- iOS: **HealthKit** (future integration)

These integrations are planned as incremental enhancements after MVP stabilization.
