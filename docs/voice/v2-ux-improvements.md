# Voice V2 — Mejoras UX de turnos

## Mejoras implementadas
1. Selector de perfil de voz con descripción.
2. Toggle de autoplay para reproducción automática.
3. Microinteracciones de estado:
   - chip de estado
   - barra de progreso en subida/procesamiento
4. Transición limpia a playback con botón de replay.
5. Historial visual resumido por turnos con:
   - audio enviado (ruta)
   - transcript
   - respuesta textual
   - metadata de audio de respuesta
6. Recuperación:
   - botón de reintentar último turno
   - mensajes de error más directos

## Mantiene flujo V1
- Continúa siendo push-to-talk por turnos.
- No se modifica el flujo de chat textual.
- No usa realtime, Realtime API, ni WebRTC.
