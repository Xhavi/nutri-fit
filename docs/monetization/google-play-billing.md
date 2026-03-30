# Google Play Billing (producción) — NutriFit

## Objetivo
Integrar suscripción mensual de **AI Premium** como producto digital recurrente bajo Google Play Billing (Android-first), sin confiar en estado local definitivo.

## Producto
- Product ID: `nutrifit_ai_monthly_499`
- Plan: suscripción mensual auto-renovable
- Beneficio: acceso recurrente a funciones IA (chat/voz) sujeto a estado backend + cuota.

## Flujo técnico
1. App inicializa `InAppPurchase` y consulta producto.
2. App inicia compra desde paywall.
3. App escucha `purchaseStream`.
4. En `purchased/restored`, app envía `purchaseToken` a `syncSubscriptionPurchase`.
5. Backend verifica con adapter (`PurchaseVerifier`) y persiste `subscriptions/{userId}`.
6. App actualiza entitlement con respuesta backend (`getPlanStatus` / sync response).

## Seguridad
- Cliente **no** concede premium definitivo por sí solo.
- `purchaseToken` se valida server-side.
- Entitlements y cuotas viven en backend.
- Endpoints IA validan entitlement antes de procesar.

## Estado actual del adapter Google Play Developer API
Preparado contractualmente, pendiente configuración real:
- Service account con permisos Android Publisher.
- Credenciales seguras (Secret Manager / env).
- Mapping de estados de SubscriptionsV2 a `SubscriptionStatus`.
- Validación de `packageName`, `productId` y binding de cuenta.
