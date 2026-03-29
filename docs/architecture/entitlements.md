# Entitlements Architecture — Freemium + AI Subscription

## Purpose
Define how NutriFit determines and enforces feature access for free and premium AI users.

## Entitlement model

### Core entities
- **User**: authenticated app account
- **Subscription state**: validated store billing status
- **Entitlement**: derived access rights (free core, premium AI)
- **Usage ledger**: metered counters per billing cycle

### Entitlement levels
1. `free_core`
   - Grants all non-AI fundamental tracking features
2. `premium_ai_active`
   - Grants AI premium features within quota limits
3. `premium_ai_limited`
   - Subscription active but one/more AI quotas exhausted
4. `premium_ai_inactive`
   - No active subscription (expired/canceled/invalid)

## Source of truth and flow
1. Client obtains purchase state from Google Play purchase flow.
2. Client sends purchase token/receipt proof to backend.
3. Backend validates state and period dates using store verification.
4. Backend writes normalized entitlement + cycle window to datastore.
5. AI request path checks entitlement and quota before processing.
6. Response includes updated usage snapshot for UI.

## Monthly cycle and reset
- Counters are scoped by `(user_id, billing_period_start, billing_period_end)`.
- Reset occurs when a new verified billing period starts.
- No rollover of unused quota between cycles.
- If verification is delayed, backend should use last known valid cycle window with safe fallback controls.

## Usage checks (server-side)
For every premium AI endpoint:

1. Validate user auth/session.
2. Resolve current entitlement state.
3. Verify subscription is active for current timestamp.
4. Read quota counter for the specific capability.
5. If limit reached, return quota-exhausted response with reset date.
6. If allowed, process request and atomically increment usage counter.

## Client behavior contract
- Show free/premium feature availability from entitlement payload.
- Display monthly usage and next reset date for premium AI.
- Handle downgrade gracefully (retain historical data; disable premium AI actions).
- Keep free core flows always operational regardless of premium state.

## Recommended datastore shape (logical)
- `users/{uid}/entitlements/current`
- `users/{uid}/entitlements/history/{period_id}`
- `users/{uid}/usage/{period_id}` with per-capability counters

(Physical schema can vary; this is a logical reference.)

## Security and abuse controls
- Never trust client-only premium flags.
- Enforce all premium gates on backend.
- Log entitlement decisions for auditability.
- Add rate limits and anomaly detection for high-frequency AI calls.

## Voice readiness (future)
- Keep `voice_minutes_used` and `voice_minutes_limit` fields optional in usage schema.
- Do not require voice infrastructure for initial text-first premium launch.
