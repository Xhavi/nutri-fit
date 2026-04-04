# Plan limits

## Catalogo inicial (server-side)

### `free`
- `ai_chat`: disabled, cuota mensual 0
- `ai_voice`: disabled, cuota mensual 0

### `premium_ai_monthly`
- `ai_chat`: enabled, cuota mensual 300
- `ai_voice`: enabled, cuota mensual 60

## Donde vive
Se define en `functions/src/services/billing/planCatalog.ts` para garantizar que el backend gobierna limites.

## Ajustes futuros recomendados
- mover catalogo a Remote Config/Firestore si producto necesita cambios sin deploy,
- separar cuota por tipo de costo (tokens input/output, audio min),
- versionar plan limits para migraciones limpias.
