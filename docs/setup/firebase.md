# Firebase setup (base integration)

Este documento deja la base para integrar Firebase en NutriFit sin exponer secretos.

## 1) Dependencias incluidas

- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `cloud_functions`

## 2) Estado actual de la integración

- Inicialización de Firebase centralizada en `lib/core/bootstrap/firebase_bootstrap.dart`.
- Si Firebase no está habilitado o falla la inicialización, la app cae automáticamente a servicios mock.
- No hay claves reales ni archivos de configuración sensibles en el repositorio.

## 3) Conectar un proyecto real de Firebase

Cuando quieras conectar Firebase real:

1. Instala FlutterFire CLI (si no lo tienes):
   ```bash
   dart pub global activate flutterfire_cli
   ```
2. Ejecuta configuración para tu entorno:
   ```bash
   flutterfire configure
   ```
3. Agrega los archivos nativos generados (`google-services.json`, `GoogleService-Info.plist`) según plataforma.
4. Si vas a usar múltiples proyectos (dev/prod), ejecuta `flutterfire configure` por cada uno y organiza la selección por `--dart-define`.

## 4) Activar Firebase real en runtime

Ejecuta con banderas de entorno:

```bash
flutter run \
  --dart-define=APP_ENV=dev \
  --dart-define=FIREBASE_ENABLED=true \
  --dart-define=FIREBASE_USE_MOCKS=false
```

> Mientras no completes la configuración de FlutterFire/nativo, usa `FIREBASE_USE_MOCKS=true`.

## 5) Alcance intencional de esta iteración

- ✅ Base técnica de inicialización.
- ✅ Wrappers base para Auth/Firestore/Functions.
- ✅ Fallback a mocks.
- ❌ No se implementa flujo completo de autenticación todavía.
