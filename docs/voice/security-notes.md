# Voice V1 security notes

## Secret handling
- `OPENAI_API_KEY` se consume sólo en backend (Cloud Functions secret).
- El cliente Flutter nunca recibe ni almacena secretos.

## Data minimization
- Sólo se procesa el contexto mínimo requerido por turno.
- Historial de conversación limitado (`recentTurns` acotado) para reducir exposición de datos.

## Safety behavior
- Prompt del coach limita respuestas a wellness/nutrición/ejercicio.
- No diagnóstico, no reemplazo de atención médica.
- Prohíbe recomendaciones extremas (purgas, ayuno extremo, etc.).
- Usa señales de seguridad y disclaimers cuando aplica.

## Input validation
- Validador rechaza payloads malformados.
- Límite de tamaño para `audio.base64`.
- Lista de turnos recientes con límite máximo.

## Operational gaps (if not fully live)
Para operación real end-to-end faltará, según entorno:
1. Configurar `OPENAI_API_KEY` en Firebase Secrets.
2. Activar `AI_VOICE_PROVIDER=openai`.
3. Deploy de función `voiceTurn`.
4. (Opcional) mover audio a URL firmada en Cloud Storage en vez de base64 en respuesta.

## Abuse considerations
- Recomendado: rate limiting por usuario + App Check + auth obligatoria.
- Recomendado: políticas de retención de audio/transcripciones y logging sin PII sensible.
