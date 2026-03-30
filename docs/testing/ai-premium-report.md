# AI Premium Report

Fecha: 2026-03-30

## Checks ejecutados

- `flutter analyze`
- `flutter test`

## Escenarios validados

1. **Usuario free intentando abrir IA**
   - Se muestra card de bloqueo premium.
   - Composer deshabilitado.
   - CTA a paywall visible.

2. **Usuario premium con cuota disponible**
   - Indicador de uso visible (`Consumido/Restante`).
   - Composer habilitado.
   - Tras envío exitoso, se refresca cuota por backend.

3. **Usuario premium con cuota agotada**
   - Aviso de cuota agotada visible.
   - Composer deshabilitado.
   - CTA a paywall visible.

4. **Voz modelada sin habilitar en V1**
   - En estado de cuota se conserva `ai_voice`.
   - Se muestra como “V1 desactivado” en paywall.

## Evidencia visual

Capturas esperadas en `docs/screenshots/ai-premium/`.
