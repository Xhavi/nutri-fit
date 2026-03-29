# Voice V1 backend implementation (server-side)

## Scope
Implementación backend **por turnos** para NutriFit Voice V1 con Cloud Functions:

1. Recibe audio desde Flutter.
2. Transcribe audio.
3. Genera respuesta del coach.
4. Sintetiza respuesta a audio.
5. Devuelve texto + audio + metadata.

> No usa Realtime API, no usa WebRTC y no mantiene streaming bidireccional.

## Endpoint
- Callable function: `voiceTurn`
- Archivo: `functions/src/index.ts`
- Región: `us-central1`

## Request contract
```json
{
  "audio": {
    "base64": "<audio_base64>",
    "mimeType": "audio/webm",
    "filename": "turn-001.webm"
  },
  "metadata": {
    "locale": "es-MX",
    "timezone": "America/Mexico_City",
    "appVersion": "1.2.0",
    "platform": "android"
  },
  "context": {
    "profile": {
      "age": 31,
      "sex": "female",
      "dietaryPreferences": ["high-protein"],
      "allergies": ["nuts"]
    },
    "goal": {
      "primaryGoal": "Perder grasa manteniendo masa muscular"
    },
    "recentMeals": [{ "summary": "Avena con yogurt", "estimatedCalories": 420 }],
    "recentActivity": [{ "summary": "Caminata", "durationMinutes": 30, "intensity": "low" }]
  },
  "conversation": {
    "conversationId": "conv_abc123",
    "recentTurns": [
      { "userText": "¿Qué ceno hoy?", "assistantText": "Haz cena ligera con proteína y vegetales." }
    ]
  },
  "voice": {
    "profileId": "alloy",
    "format": "mp3"
  }
}
```

## Response contract
```json
{
  "userTranscript": "¿Qué puedo comer después del gym?",
  "assistantText": "Te conviene una combinación de proteína magra y carbohidrato complejo...",
  "assistantAudio": {
    "base64": "<audio_base64>",
    "mimeType": "audio/mpeg"
  },
  "voiceProfileUsed": "alloy",
  "safety": {
    "containsSensitiveContent": false,
    "disclaimerShown": false,
    "escalationRecommended": false
  },
  "meta": {
    "provider": "openai",
    "requestId": "resp_123",
    "model": "gpt-4.1-mini",
    "transcriptionModel": "gpt-4o-mini-transcribe",
    "ttsModel": "gpt-4o-mini-tts",
    "locale": "es-MX"
  }
}
```

## Modular design
- `transcriptionService.ts`: STT (o mock).
- `voiceCoachResponseService.ts`: genera texto coach usando Responses API (reusa safety y prompt existentes).
- `speechSynthesisService.ts`: TTS (o mock).
- `voiceTurnService.ts`: orquesta STT -> coach -> TTS y arma respuesta final.

## Failure modes
- Si no hay `OPENAI_API_KEY` y provider=openai -> error `failed-precondition`.
- Si provider=mock -> retorna transcripción/audio simulados para desbloquear integración cliente.

## Notas de despliegue
Para ejecución real se requiere:
- Secret `OPENAI_API_KEY` configurado en Firebase Functions.
- `AI_VOICE_PROVIDER=openai`.
- Deploy de Functions con estas variables.
