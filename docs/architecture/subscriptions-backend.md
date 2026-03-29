# Subscriptions backend (source of truth)

## Objetivo
Mover monetización y control premium al backend para que Flutter no tome decisiones de acceso por sí solo.

## Decisión técnica
NutriFit ya usa **Firebase Cloud Functions** y `onCall`, así que este backend de suscripciones se implementa ahí (no en Cloud Run por ahora).

## Principios
- Entitlements y cuotas viven en backend.
- OpenAI se consume siempre server-side.
- El cliente solo consulta estado y solicita acciones; no autoriza premium localmente.

## Modelo de datos (Firestore)

### `subscriptions/{userId}`
Documento por usuario:

- `userId`
- `planId`: `free` | `premium_ai_monthly`
- `status`: `inactive` | `trialing` | `active` | `past_due` | `canceled` | `expired`
- `provider`: `unknown` | `app_store` | `play_store` | `stripe`
- `providerProductId` (opcional)
- `providerSubscriptionId` (opcional)
- `currentPeriodStartAt`, `currentPeriodEndAt` (ISO)
- `canceledAt` (opcional)
- `updatedAt`
- `entitlements`:
  - `ai_chat`: enabled/source/reason
  - `ai_voice`: enabled/source/reason

### `monthlyUsageCounters/{userId_yyyy-mm}`
Contadores mensuales por usuario y mes:

- `userId`
- `monthKey` (ej. `2026-03`)
- `used.ai_chat`
- `used.ai_voice`
- `updatedAt`

## Endpoints callable
- `getPlanStatus`
- `validatePremiumFeature`
- `registerAiUsage`
- `getRemainingQuota`
- `syncSubscriptionPurchase` (adapter placeholder)

## Integración con funciones IA
`aiCoachChat` y `voiceTurn` ahora:
1. requieren usuario autenticado,
2. validan entitlement/cuota backend,
3. ejecutan IA,
4. registran consumo.

## Compra real (adapter)
`syncSubscriptionPurchase` usa la interfaz `PurchaseVerifier`.
Actualmente incluye `NotImplementedPurchaseVerifier` para conectar App Store / Play / Stripe cuando esté listo, sin romper contratos backend.
