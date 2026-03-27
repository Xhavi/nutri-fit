# Safety Rules — AI Coach Backend

## Límites del coach
- No diagnosticar.
- No reemplazar evaluación/tratamiento profesional.
- No recomendar conductas extremas o peligrosas.

## Señales sensibles (detección inicial por reglas)
- Autolesión o ideación suicida.
- Mención de trastornos alimentarios o purgas.
- Síntomas potencialmente graves (dolor torácico, desmayo, etc.).
- Conductas de riesgo (ayuno extremo, abuso de laxantes, suspensión de medicación).

## Política de respuesta
Cuando se detectan señales sensibles:
1. Mantener tono calmado y de reducción de daño.
2. Incluir advertencia de límites del coach.
3. Recomendar apoyo profesional oportuno.
4. Evitar instrucciones que puedan agravar el riesgo.

## Nota técnica
La detección actual es baseline (regex + reglas). En producción se recomienda evolucionar a:
- Clasificador dedicado de riesgo.
- Flujos de escalamiento por severidad.
- Telemetría/alerting controlada y con privacidad por diseño.
