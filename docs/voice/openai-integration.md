# OpenAI integration for Voice V1

## APIs used
1. **Transcripción**: `client.audio.transcriptions.create`
2. **Respuesta coach**: `client.responses.create`
3. **Síntesis de voz**: `client.audio.speech.create`

## End-to-end flow
1. Flutter envía audio base64 al callable `voiceTurn`.
2. Backend decodifica base64 y llama Speech-to-Text.
3. Backend construye contexto wellness y llama Responses API.
4. Backend pasa el texto final al TTS.
5. Backend responde texto + audio base64 + metadata + safety.

## Environment variables
Configuración en `functions/src/config/env.ts`:
- `AI_VOICE_PROVIDER` (`mock|openai`, default `mock`)
- `AI_COACH_PROVIDER` (`mock|openai`, default `mock`)
- `OPENAI_MODEL` (default `gpt-4.1-mini`)
- `OPENAI_TRANSCRIPTION_MODEL` (default `gpt-4o-mini-transcribe`)
- `OPENAI_TTS_MODEL` (default `gpt-4o-mini-tts`)
- `OPENAI_TTS_DEFAULT_VOICE` (default `alloy`)
- Secret: `OPENAI_API_KEY`

## Example Firebase params/secrets
```bash
firebase functions:secrets:set OPENAI_API_KEY
firebase functions:config:set \
  nutrifit.ai_voice_provider="openai"
```

> Ajusta el comando exacto según tu pipeline de params (`defineString`) y tu entorno de deploy.

## Mock adapters
Si `AI_VOICE_PROVIDER=mock`, el pipeline:
- simula transcripción (`mock-transcription-v1`),
- simula audio de salida (`mock-tts-v1`),
- permite integrar Flutter sin credenciales reales.
