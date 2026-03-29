# Voice V2 Testing Report

## Escenarios objetivo
1. Seleccionar perfil de voz y persistir preferencia.
2. Grabar turno por PTT y enviar.
3. Ver feedback de estados durante upload/processing.
4. Validar autoplay on/off.
5. Reproducir nuevamente última respuesta.
6. Reintentar último turno ante error transitorio.
7. Confirmar que chat de texto sigue operativo.

## Resultado de validaciones en este entorno
- ✅ `npm --prefix functions run build` (TypeScript compila).
- ❌ `npm --prefix functions run lint` (falla por baseline de reglas de estilo e indentación en múltiples archivos existentes del módulo `functions/`).
- ⚠️ `flutter test` no ejecutable en este contenedor (`flutter: command not found`).
- ⚠️ `flutter run` no ejecutable en este contenedor (`flutter: command not found`).

## Pruebas manuales de app y capturas
No fue posible levantar la app Flutter ni capturar pantallas desde este entorno por ausencia de Flutter SDK y herramienta de screenshot/browser para UI.

Directorio de destino de capturas mantenido para ejecución local:
- `docs/screenshots/voice-v2/`
