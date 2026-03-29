# Voice E2E Report — NutriFit V1 + V2

Fecha: 2026-03-29 (UTC)

## 1) Plan de prueba aplicado
1. Identificar flujos V1/V2 de voz desde código y documentación.
2. Validar entorno disponible para ejecución Flutter.
3. Ejecutar comandos solicitados: `flutter pub get`, `flutter analyze`, `flutter test`.
4. Intentar levantar entorno de ejecución para pruebas manuales.
5. Registrar evidencias reales (sin inventar resultados) y consolidar bugs/pendientes.

## 2) Entorno utilizado
- Repositorio: `/workspace/nutri-fit`
- SO/contendor: Linux (CI container)
- Resultado de tooling Flutter: **no disponible** (`flutter: command not found`)
- Dispositivos/emulador: **no verificable** (sin Flutter CLI)
- Backend functions (TypeScript): build local **OK** (`npm --prefix functions run build`)

## 3) Ejecución de comandos requeridos
| Comando | Resultado | Evidencia |
|---|---|---|
| `flutter pub get` | ⚠️ No ejecutable | `/bin/bash: line 1: flutter: command not found` |
| `flutter analyze` | ⚠️ No ejecutable | `/bin/bash: line 1: flutter: command not found` |
| `flutter test` | ⚠️ No ejecutable | `/bin/bash: line 1: flutter: command not found` |

Comando adicional de soporte:
| Comando | Resultado | Evidencia |
|---|---|---|
| `npm --prefix functions run build` | ✅ OK | `tsc` completó sin errores |

## 4) Flujos/casos enumerados y estado

### Leyenda
- **PASÓ**: verificado con ejecución real.
- **FALLÓ**: ejecutado, con error reproducible.
- **NO VERIFICADO**: sin capacidad de ejecución en este entorno.

| ID | Caso | Pasos resumidos | Resultado observado | Estado | Causa / notas |
|---|---|---|---|---|---|
| V-01 | Push-to-talk (mantener pulsado) inicia grabación | Entrar AI Coach > mantener botón voz | No se pudo ejecutar UI | NO VERIFICADO | Flutter no instalado en contenedor |
| V-02 | Permisos de micrófono (allow) | Primer uso de PTT > conceder permiso | No se pudo ejecutar UI | NO VERIFICADO | Sin runtime móvil |
| V-03 | Permisos de micrófono (deny) | Primer uso de PTT > negar permiso | No se pudo ejecutar UI | NO VERIFICADO | Sin runtime móvil |
| V-04 | Grabación + stop + envío | Mantener pulsado > soltar / botón detener | No se pudo ejecutar UI | NO VERIFICADO | Sin runtime móvil |
| V-05 | Cancelación de grabación | Iniciar grabación > cancelar | No se pudo ejecutar UI | NO VERIFICADO | Sin runtime móvil |
| V-06 | Reintento del último turno | Tras error/transitorio > botón reintentar | No se pudo ejecutar UI | NO VERIFICADO | Sin runtime móvil |
| V-07 | Envío al backend (`voiceTurn`) | Grabar y enviar audio | Contrato y cliente presentes en código | NO VERIFICADO (manual) | Sólo revisión estática |
| V-08 | Transcripción recibida | Backend devuelve `userTranscript` | Parsing implementado | NO VERIFICADO (manual) | Sólo revisión estática |
| V-09 | Respuesta textual del coach | Ver `assistantText` en UI | Binding implementado | NO VERIFICADO (manual) | Sólo revisión estática |
| V-10 | Reproducción de audio respuesta | Backend devuelve audio > autoplay/replay | Lógica implementada | NO VERIFICADO (manual) | Sólo revisión estática |
| V-11 | Perfiles de voz | Cambiar perfil y usarlo en request | Persistencia y mapeo implementados | NO VERIFICADO (manual) | Sólo revisión estática |
| V-12 | Autoplay ON/OFF | Toggle autoplay y observar reproducción | Lógica implementada | NO VERIFICADO (manual) | Sólo revisión estática |
| V-13 | Replay de respuesta | Botón “Reproducir respuesta” | Lógica implementada | NO VERIFICADO (manual) | Sólo revisión estática |
| V-14 | Convivencia voz + chat texto | En AI Coach enviar texto y usar voz | Ambos widgets coexisten en página | NO VERIFICADO (manual) | Sólo revisión estática |

## 5) Evidencia por revisión de código (funcionalidad implementada)
- `VoiceTurnControls` contiene controles de PTT, cancelación, reintento, replay, selector de perfil y switch autoplay.
- `VoiceTurnController` implementa: solicitud de permisos, grabación, envío al backend, manejo de errores, replay, cancelación, retry y persistencia de preferencias.
- `FirebaseAiVoiceApiClient` llama a Cloud Function `voiceTurn` y parsea `VoiceTurnResponse`.
- `AiCoachPage` monta chat de texto y controles de voz en la misma pantalla (convivencia).

## 6) Bugs encontrados (honestos)

### B-01 (UX/estado): `retryLastTurn()` no agrega entrada al historial
- Severidad: media-baja.
- Evidencia: en `stopRecording()` sí se agrega a `history`; en `retryLastTurn()` no.
- Impacto: la lista de historial puede omitir interacciones reintentadas.

### B-02 (UX/estado): `stopPlayback()` deja `status` en `idle`
- Severidad: baja.
- Evidencia: `stopPlayback()` fuerza `VoiceTurnStatus.idle` en vez de `responseReady` cuando existe `lastResponse`.
- Impacto: estado visual puede sugerir que no hay respuesta lista tras detener audio.

### B-03 (robustez): `cancelRecording()` sin manejo explícito de excepción
- Severidad: baja.
- Evidencia: `await _recorder.cancelRecording();` sin `try/catch` local.
- Impacto: si el recorder lanza error, puede propagarse y degradar UX.

## 7) Pendientes para cierre QA real
1. Instalar Flutter SDK estable en runner o ejecutar en máquina local.
2. Levantar emulador Android/iOS (o dispositivo físico con micrófono).
3. Ejecutar batería manual completa y adjuntar capturas reales en `docs/screenshots/voice-qa/`.
4. Re-ejecutar `flutter analyze` y `flutter test`.
5. Validar backend real con credenciales/entorno habilitado.
6. Confirmar escenarios de permisos (allow/deny/permanent deny).

## 8) Resultado global
- **Validación automática Flutter:** bloqueada por entorno.
- **Validación manual E2E:** bloqueada por entorno.
- **Validación estática de implementación V1/V2:** consistente con los flujos solicitados, con 3 hallazgos de mejora arriba listados.

