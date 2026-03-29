# Usage quotas de IA

## Features
- `ai_chat`
- `ai_voice`

## Reglas
- Usuario free: no accede a features premium.
- Usuario premium: acceso sujeto a `monthlyQuota` por feature.
- Si `remaining <= 0`, backend devuelve `monthly_quota_exceeded`.

## Reset mensual
No se requiere job destructivo.

El reset se resuelve por diseño con `monthKey` (`YYYY-MM`, UTC):
- al cambiar mes, se lee/escribe otro documento en `monthlyUsageCounters`,
- el nuevo documento inicia en 0,
- los históricos quedan para auditoría/costos.

## Registro de consumo
`registerAiUsage` incrementa contador por feature.
También se invoca internamente al completar `aiCoachChat` y `voiceTurn`.

## Payloads de ejemplo

### validatePremiumFeature (request)
```json
{
  "feature": "ai_chat"
}
```

### validatePremiumFeature (response)
```json
{
  "allowed": true,
  "planId": "premium_ai_monthly",
  "status": "active",
  "monthKey": "2026-03",
  "quota": 300,
  "used": 42,
  "remaining": 258
}
```

### registerAiUsage (request)
```json
{
  "feature": "ai_chat",
  "amount": 1
}
```

### registerAiUsage (quota agotada)
```json
{
  "allowed": false,
  "reason": "monthly_quota_exceeded",
  "planId": "premium_ai_monthly",
  "status": "active",
  "monthKey": "2026-03",
  "quota": 300,
  "used": 300,
  "remaining": 0
}
```
