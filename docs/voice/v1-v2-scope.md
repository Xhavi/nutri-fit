# Voice Scope: V1 vs V2

## V1 (esta fase)
- Chat de texto existente + entrada por voz PTT.
- Usuario mantiene pulsado o toca micrófono para iniciar grabación.
- Al detener, se envía audio al backend en un turno.
- Respuesta del backend: texto + audio.
- Reproducción local del audio recibido.
- UX mínima robusta de error/carga/estado.

## V2 (sobre la base de V1)
- Mejorar naturalidad de la voz de respuesta.
- Estados UX más detallados (captura, subiendo, transcribiendo, generando, reproduciendo).
- Soporte de perfiles de voz.
- Instrucciones de estilo de voz.
- Reproducción más fluida.

## Fuera de alcance explícito
- V3 realtime.
- Realtime API.
- WebRTC.
- Conversación full duplex.
- Speech-to-speech continuo.

## Criterio de arquitectura
Todo debe seguir patrón por turnos request/response para minimizar complejidad inicial y preservar mantenibilidad.
