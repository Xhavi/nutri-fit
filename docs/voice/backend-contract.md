# Backend Contract (Flutter ↔ Server) — Voice Turn

## Endpoint lógico
- `aiVoiceTurn` (callable/function o HTTP protegido)

## Request (turn-based)

```json
{
  "inputAudioBase64": "<base64>",
  "audioMimeType": "audio/m4a",
  "transcript": "opcional si cliente ya lo tiene",
  "userContext": {
    "userId": "abc123",
    "goal": "Mejorar hábitos sostenibles",
    "locale": "es-MX",
    "additional": {
      "recentMeals": [],
      "recentActivity": []
    }
  },
  "voiceProfile": {
    "id": "calm_es_female_1",
    "label": "Calm ES",
    "locale": "es-ES",
    "styleInstructions": "tono cálido y motivador",
    "isDefault": true
  },
  "voiceStyleInstructions": "respuesta breve, clara, empática",
  "turnId": "turn-001",
  "conversationId": "coach-chat-123",
  "locale": "es-ES"
}
```

## Response

```json
{
  "assistantText": "Hoy puedes priorizar...",
  "outputAudioBase64": "<base64>",
  "outputAudioMimeType": "audio/mpeg",
  "transcription": {
    "text": "quiero una cena ligera",
    "languageCode": "es",
    "confidence": 0.93,
    "isPartial": false
  },
  "metadata": {
    "requestId": "req-123",
    "provider": "openai",
    "model": "gpt-4.1-mini",
    "turnMode": "ptt",
    "latencyMs": 1240
  }
}
```

## Validaciones backend recomendadas
- Tamaño máximo de audio por turno.
- MIME type permitido.
- Duración máxima de grabación.
- Sanitización de campos de contexto.
- Timeouts y errores tipados.

## Seguridad
- OpenAI key solo server-side.
- Autenticación/autorización obligatoria en función backend.
- Logging sin exponer datos sensibles crudos de audio.

## Evolución V2
- Mantener backward compatibility del contrato.
- Extender metadata de voz sin romper clientes existentes.
