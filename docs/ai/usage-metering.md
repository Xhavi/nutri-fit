# AI Usage Metering (NutriFit)

## Features con metering

- `ai_chat` (activo en premium V1)
- `ai_voice` (modelado, no habilitado comercialmente en V1)

## Flujo de metering

1. Cliente solicita estado de plan (`getPlanStatus`) para pintar cuota inicial.
2. Cliente usa `getRemainingQuota(feature: ai_chat)` para refrescar contador tras turnos.
3. Backend valida acceso por request (`validateFeatureAccess`).
4. Si procede, procesa IA y registra consumo (`registerFeatureUsage(userId, 'ai_chat', 1)`).

## Ciclo y reset

- `monthKey`: `YYYY-MM` en UTC.
- Cada documento de uso está segmentado por `(userId, monthKey)`.
- El reset ocurre al comenzar un nuevo `monthKey`.

## Campos relevantes de respuesta

- `quota`: límite mensual del feature
- `used`: consumo acumulado en mes actual
- `remaining`: `max(0, quota - used)`
- `reason`: motivo de bloqueo (`feature_not_entitled`, `subscription_not_active`, `monthly_quota_exceeded`)

## Reglas de robustez

- El metering vive en backend para evitar manipulación cliente.
- El cliente debe tolerar fallos de refresco y mantener último snapshot conocido.
- Nunca habilitar UI premium solo por estado local de compra sin validación backend.
