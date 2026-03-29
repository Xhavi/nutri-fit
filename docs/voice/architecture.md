# Voice Architecture (V1/V2, turn-based)

## Objetivo
Diseñar una base escalable para interacción por voz en NutriFit manteniendo el chat actual y respetando seguridad: **OpenAI solo en backend**.

## Alcance técnico
- Modo **por turnos** (push-to-talk / tap-to-talk).
- No realtime continuo.
- No Realtime API.
- No WebRTC.
- No full duplex speech-to-speech.

## Principios
1. Feature-first + capas explícitas.
2. Cliente Flutter sin claves secretas.
3. Contrato claro Flutter ↔ backend.
4. Dependencias de audio desacopladas por contratos.

## Estructura propuesta
```text
lib/features/ai_voice/
  presentation/
    controllers/
    widgets/
  application/
  domain/
    models/
    repositories/
    contracts/
  data/
    clients/
    repositories/
    services/
```

## Flujo de un turno de voz
1. UI activa grabación (PTT).
2. `AudioRecorder` produce audio local.
3. `VoiceTurnController` construye `VoiceTurnRequest`.
4. `AiVoiceRepository` envía al backend (`aiVoiceTurn`).
5. Backend hace STT/LLM/TTS server-side.
6. Flutter recibe `VoiceTurnResponse` con texto + audio.
7. `AudioPlayer` reproduce audio de salida y UI actualiza estado.

## Integración con ai_coach existente
- El chat de texto continúa como flujo primario.
- Voz se agrega como módulo complementario (`VoiceTurnControls`).
- A futuro se podrá mapear la respuesta de voz a la misma timeline de mensajes del coach.

## Estados de aplicación (base)
- `idle`
- `recording`
- `uploading`
- `processing`
- `playing`
- `done`
- `error`

## TODO V1
- Integrar plugin real para grabación (permissions + formato).
- Integrar reproducción de bytes de audio.
- Endpoint backend `aiVoiceTurn` productivo.
- Mapeo de transcript y respuesta al historial del chat.

## TODO V2
- Naturalidad de voz (prosodia, pausas, estilo).
- Perfiles de voz configurables.
- Instrucciones de estilo de voz por usuario/contexto.
- Mejoras UX de estados, interrupciones y feedback de latencia.
- Reproducción más fluida (buffering/segmentación).
