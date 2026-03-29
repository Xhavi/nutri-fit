# Voice V2 — Perfiles de voz

## Objetivo
V2 refina la experiencia de voz por turnos de V1 sin introducir realtime ni WebRTC.

## Perfiles soportados
- `warm` (cálida)
- `energetic` (energética)
- `calm` (calmada)
- `professional` (profesional)

## Mapeo por perfil
Cada perfil se mapea a:
1. `profileId`: identificador enviado a backend para seleccionar voz base.
2. `styleInstructions`: instrucciones expresivas para TTS.
3. `rate`: factor sugerido de ritmo (1.00 = neutral).
4. `intent`: intención comunicativa (`friendly`, `motivational`, `reassuring`, `structured`).

## Compatibilidad con V1
- El bloque `voice` sigue siendo opcional.
- Si no se envía perfil, backend usa `coach_default`.
- `styleInstructions`, `rate`, `intent` son opcionales y no rompen contratos previos.

## Persistencia en app
- Perfil seleccionado se guarda localmente en `ai_voice.selected_profile.v2`.
- Se restaura al abrir la pantalla y mantiene fallback seguro al perfil default.
