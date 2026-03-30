# AI Premium Access Rules (NutriFit)

## Objetivo
Definir el gating comercial del AI Coach para V1 premium con cuotas mensuales controladas por backend.

## Reglas de acceso

1. **Plan gratis (`free`)**
   - No tiene entitlement para `ai_chat`.
   - No puede abrir flujo operativo del AI Coach (composer bloqueado + CTA a paywall).

2. **Plan premium (`premium_ai_monthly`) activo**
   - Puede usar `ai_chat` solo si `remaining > 0` para el mes actual (`monthKey` UTC).
   - El backend decide acceso final por request.

3. **Premium con cuota agotada**
   - Si `remaining <= 0`, el backend responde bloqueo por cuota (`monthly_quota_exceeded`).
   - La app debe mostrar aviso de cuota agotada y ruta a paywall/renovación.

## Principios de enforcement

- El cliente **nunca** es la fuente de verdad para premium; solo refleja estado de backend.
- El endpoint `aiCoachChat` valida entitlement+cuota antes de procesar.
- Tras respuesta exitosa, `aiCoachChat` registra consumo (`+1` en `ai_chat`).

## Contrato de UX mínimo

- Usuario gratis intentando IA: card de bloqueo y botón “Ver planes”.
- Premium con cuota disponible: chat habilitado + indicador de uso restante.
- Premium con cuota agotada: composer deshabilitado + aviso de renovación + CTA.

## Voz (V1 comercial)

- `ai_voice` permanece modelado como feature con cuota en el estado de entitlements.
- La experiencia comercial de voz se mantiene desactivada para V1.
- El modelado evita migraciones futuras al activar voz en V2.
