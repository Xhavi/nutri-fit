# Subscription lifecycle (Google Play -> Backend -> Entitlement)

## Estados de compra (cliente)
- `pending`: compra en proceso, estado temporal.
- `purchased`: compra completada en Play, pendiente verificación backend.
- `restored`: restauración detectada, pendiente verificación backend.
- `canceled`: cancelación del flujo de compra.
- `error`: error técnico de compra.

## Estados de suscripción (backend)
- `active`, `trialing` -> premium habilitado.
- `canceled` -> premium solo hasta `currentPeriodEndAt` (según verificación).
- `expired`, `inactive`, `past_due` -> premium deshabilitado.

## Transiciones críticas
1. **Compra exitosa**
   - Cliente recibe `purchased`.
   - Envía token al backend.
   - Backend verifica y activa entitlement.

2. **Restauración**
   - Cliente ejecuta `restorePurchases`.
   - Re-sincroniza token/estado con backend.

3. **Cancelación**
   - Backend marca `canceled`.
   - Cliente refleja estado y fecha de fin de periodo.

4. **Expiración**
   - Backend marca `expired`.
   - Cliente revoca premium automáticamente.

5. **Error**
   - Cliente mantiene estado no-premium definitivo.
   - Ofrece reintento/restauración.

## Regla de oro
La decisión final de entitlement siempre la toma backend; cliente solo mantiene estado temporal de UX.
