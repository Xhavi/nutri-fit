# Production checklist — Google Play subscription

## Play Console
- [ ] Suscripción `nutrifit_ai_monthly_499` creada y activa.
- [ ] Base plan mensual activo con precio final.
- [ ] Testers internos cerrados configurados.
- [ ] Políticas de disclosures y precio verificadas.

## App Android
- [x] Consulta de producto en runtime.
- [x] Inicio de compra desde paywall.
- [x] Listener de cambios de compra.
- [x] Restauración de compras.
- [x] Estado local temporal para UX.

## Backend
- [x] Endpoint `syncSubscriptionPurchase`.
- [x] Contrato `PurchaseVerifier` desacoplado.
- [x] Persistencia en `subscriptions/{userId}`.
- [ ] Adapter real Google Play Developer API.
- [ ] Job/RTDN para refresco de estado (cancel/expire sin abrir app).

## Seguridad
- [x] Cliente no es source of truth.
- [x] Entitlements aplicados server-side.
- [x] Endpoints IA condicionados por entitlement backend.
- [ ] Validación estricta de package/product/account en verifier real.

## Operación
- [ ] Alertas de fallas de verificación.
- [ ] Dashboard de conversiones/cancelaciones/expiraciones.
- [ ] Runbook de incidentes de billing.
