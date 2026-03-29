# Monetization Strategy — NutriFit Freemium

## Executive summary
NutriFit monetization is redesigned as:

- **Android-first launch**
- **Free core wellness tracking**
- **Premium AI via monthly auto-renewing subscription**
- **Price:** **USD $4.99/month**
- **Store alignment:** Google Play Billing

## Why AI premium is subscription (not one-time payment)
AI coaching has recurring variable costs and ongoing maintenance:

1. **Per-request inference cost** (LLM tokens, moderation, orchestration)
2. **Server-side operations** (Firebase Blaze + backend infrastructure)
3. **Continuous model/prompt/safety tuning**
4. **Abuse prevention and reliability monitoring**

A one-time payment would create negative unit economics for active users. A monthly subscription keeps margins sustainable while preserving a generous free core.

## Business principles
- Keep habit tracking accessible: free tier remains functional and useful on its own.
- Monetize differentiated AI value, not basic health logging.
- Start with text-first AI to reduce launch complexity/cost.
- Keep voice as planned premium evolution, not day-1 dependency.

## Billing model (implementation target)

### Store
- Google Play Billing subscription product.
- Initial plan: single base plan at **$4.99/month** (auto-renewing).

### Backend source of truth
- Server validates purchase state and persists entitlement state.
- Client renders feature access based on entitlement status.
- AI endpoints require server-side entitlement check before completion.

### Cancellation / grace / account hold
NutriFit should honor Google Play subscription states:
- Active: premium access granted
- In grace/account hold: access policy explicitly defined in entitlement rules
- Expired/canceled: premium revoked, free core preserved

(Exact state transitions are documented in `docs/architecture/entitlements.md`.)

## Pricing rationale for $4.99/month
- Low-friction entry point for wellness consumers
- Enough room to cover average text AI costs plus infra/support
- Supports product iteration cadence without one-off upsell pressure

## Monthly quota reset policy
Premium AI usage quotas should reset on each subscriber billing cycle:

- Reset key: current active billing period start/end from validated purchase data
- Reset event: automatic at period renewal
- No rollover by default (conservative margin protection)
- Mid-cycle upgrade/downgrade behavior should follow store billing state

## Guardrails for financial sustainability
- Conservative monthly caps at launch
- Strict server-side metering
- Transparent in-app usage counters and warnings near limits
- Ability to adjust caps by remote config after observing real-world usage

## Non-goals for this phase
- No one-time AI unlock SKU
- No iOS-first billing design
- No in-app implementation details in this document (strategy only)
