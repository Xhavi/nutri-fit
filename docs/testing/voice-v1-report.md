# Voice V1 Testing Report

## Fecha
- 2026-03-29 (UTC)

## Alcance
- Flujo push-to-talk por turnos para `ai_voice` integrado en `ai_coach`.
- Integración de cliente Flutter contra endpoint real `voiceTurn` (callable).
- Serialización de request/response con transcript, respuesta textual, audio y metadata.
- Estados visuales explícitos: grabación, subida, procesamiento backend, respuesta lista, reproducción.
- Manejo de errores: permisos, backend/red, timeout, audio vacío/corrupto.

## Comandos ejecutados
| Comando | Resultado | Notas |
|---|---|---|
| `flutter analyze` | ⚠️ | `flutter: command not found` en este entorno. |
| `flutter test` | ⚠️ | `flutter: command not found` en este entorno. |
| `flutter run -d emulator-5554` | ⚠️ | `flutter: command not found` en este entorno. |
| `dart format ...` | ⚠️ | `dart: command not found` en este entorno. |

## Validación funcional (revisión de código en este entorno)
- El cliente Firebase de voz ahora llama `voiceTurn` (backend real V1) con timeout de 60s.
- El contrato del request Flutter se adaptó al backend:
  - `audio.base64`, `audio.mimeType`
  - `metadata.locale`
  - `context` (mapeado desde `VoiceUserContext`)
  - `conversation` y `voice` opcionales
- El contrato del response Flutter ahora procesa:
  - `userTranscript`
  - `assistantText`
  - `assistantAudio.base64` + `assistantAudio.mimeType`
  - `meta` + `voiceProfileUsed` + `safety`
- El controlador V1 ahora refleja estados separados de subida y procesamiento backend.
- Se añadió validación de audio grabado vacío/corrupto antes de enviar al backend.
- Se mantienen archivos temporales para grabación y respuesta de audio (reproducción local desde archivo temporal).
- El chat de texto no fue modificado y permanece como canal alternativo.

## Capturas
- No fue posible generar capturas ni prueba manual de app porque este entorno no dispone de `flutter` ejecutable.
- Carpeta objetivo para evidencia: `docs/screenshots/voice-v1-integration/`.
