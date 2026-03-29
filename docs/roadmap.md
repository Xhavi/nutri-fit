# Roadmap — NutriFit (Freemium + AI Subscription)

## Phase 0 — Foundation (completed)
- Product vision and architecture baseline
- Repository conventions and CI baseline

## Phase 1 — Core free wellness MVP (current)
- Stabilize free core tracking flows:
  - meal logging
  - water logging
  - exercise logging
  - goals and progress
  - dashboard and basic reminders
- Maintain Android-first quality baseline

## Phase 2 — Freemium productization
- Finalize free vs premium product boundaries
- Define entitlement architecture and usage metering model
- Define premium AI packaging for Google Play Billing
- Add paywall/upgrade UX copy (wellness framing, non-medical)

## Phase 3 — Premium AI launch (text-first)
- Release AI nutrition coach for premium subscribers
- Personalized recommendations + menu adjustments
- Conversational follow-up experience
- Apply monthly usage limits and reset rules

## Phase 4 — Billing + backend hardening
- Implement Google Play Billing integration (Android)
- Server-side purchase validation and entitlement sync
- Quota metering, observability, abuse controls
- Subscription lifecycle handling (renewal, cancellation, grace, hold)

## Phase 5 — Optimization and expansion
- Tune limits and pricing via real usage/cost data
- Improve conversion and retention loops
- Prepare iOS subscription rollout after Android validation

## Phase 6 — Voice premium evolution (future)
- Introduce voice for premium AI with strict monthly limits
- Keep text experience as baseline for cost control and reliability
- Iterate voice UX only after text economics remain healthy
