# Environments (dev/prod)

NutriFit usa `--dart-define` para separar configuración por entorno, sin hardcodear secretos.

## Variables soportadas

- `APP_ENV`: `dev` | `prod`
- `FIREBASE_ENABLED`: `true` | `false`
- `FIREBASE_USE_MOCKS`: `true` | `false`

## Configuración recomendada

### Desarrollo local sin Firebase real

```bash
flutter run \
  --dart-define=APP_ENV=dev \
  --dart-define=FIREBASE_ENABLED=false \
  --dart-define=FIREBASE_USE_MOCKS=true
```

### Desarrollo con Firebase real

```bash
flutter run \
  --dart-define=APP_ENV=dev \
  --dart-define=FIREBASE_ENABLED=true \
  --dart-define=FIREBASE_USE_MOCKS=false
```

### Producción (build)

```bash
flutter build apk \
  --dart-define=APP_ENV=prod \
  --dart-define=FIREBASE_ENABLED=true \
  --dart-define=FIREBASE_USE_MOCKS=false
```

## Notas de seguridad

- Nunca subir secretos privados al repositorio.
- Las API keys públicas de Firebase no sustituyen reglas de seguridad.
- Aplicar reglas de Firestore y Functions con mínimo privilegio.
