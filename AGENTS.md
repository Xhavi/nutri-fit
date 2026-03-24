# AGENTS.md — NutriFit repository working agreements

## Project intent
NutriFit is a Flutter/Dart mobile app focused on nutrition tracking, exercise logging, wellness progression, and AI coaching.

## Core technical stack
- Primary stack: **Flutter + Dart**.
- Code must be **null-safe** and aligned with modern Dart/Flutter best practices.

## Architecture and code organization
- Use a **feature-first architecture** by default.
- Prefer **clean, modular, testable code** over monolithic implementations.
- Keep layers explicit (presentation, domain, data) when applicable.

## Workflow expectations
- **Always propose a short plan before implementing code changes.**
- Keep changes **small, incremental, and reviewable**.
- Prefer focused commits that map to one logical purpose.

## Security and privacy
- Never embed secrets (API keys, tokens, credentials) in client code.
- Use environment/config strategies for sensitive values.

## Product and safety boundaries
- The app must **not** present itself as medical diagnosis or treatment.
- AI coaching outputs must be framed as wellness guidance, not clinical advice.

## Dependency governance
- Ask for explicit confirmation before introducing heavy/unplanned dependencies
  (especially analytics SDKs, AI SDKs, background services, or large UI/state packages).

## Git rules
- Do not use `git add .`.
- Do not perform force-push (`git push --force` / `git push -f`).
- Prefer branch-based work and clear commit messages.
