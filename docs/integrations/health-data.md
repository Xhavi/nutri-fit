# Device health data integration (Health Connect + HealthKit)

## Objetivo
Definir una integración de datos de salud que sea:
- multiplataforma (Android/iOS),
- desacoplada del proveedor/plugin,
- segura frente a permisos denegados o configuración nativa incompleta,
- escalable para nuevas métricas.

## Diseño aplicado en esta iteración
Se añadió un módulo `features/health` con capas explícitas:

- **Contratos (dominio)**
  - `HealthDataSource`: lectura de datos normalizados.
  - `HealthPermissionService`: estado y solicitud de permisos.
- **Modelos normalizados (dominio)**
  - `HealthMetricType` (`steps`, `weight`, `activityMinutes`).
  - `HealthDataBundle` + samples tipados.
- **Mappers (data)**
  - Conversión de payload dinámico (wire/native/plugin) a modelos internos.
- **Servicios/adaptadores (data)**
  - `PlatformHealthPermissionService` y `PlatformHealthDataSource` usando `MethodChannel`.
  - Si no existe implementación nativa, responden fallback seguro (vacío/unsupported).

## Estado actual (MVP scaffold)
- ✅ Lectura de **pasos**: contrato y pipeline listos.
- ✅ Lectura de **peso**: contrato y pipeline listos.
- ✅ Lectura de **actividad básica** (minutos activos): contrato y pipeline listos.
- ⚠️ Implementación nativa real aún pendiente (`MethodChannel`).

Este enfoque evita romper compilación y permite completar nativo por fases.

## Integración recomendada para producción

### Opción recomendada: plugin `health`
Se recomienda evaluar el plugin `health` para acelerar integración real porque unifica:
- Android: Health Connect
- iOS: HealthKit

**Motivo técnico**: reduce mantenimiento de código nativo y provee una capa común para permisos y lectura.

> Importante: incluso usando plugin, mantener esta arquitectura interna (contratos + mappers) para no acoplar la app a una librería específica.

## Android — Health Connect (guía)

### Requisitos
- Android 8+ (según casos) y soporte de Health Connect vía app/sistema según dispositivo.
- Configuración de permisos en `AndroidManifest.xml`.

### Permisos típicos (ejemplo conceptual)
- lectura de pasos,
- lectura de peso,
- lectura de actividad/ejercicio.

Además, puede requerirse declarar intención de uso de Health Connect y metadatos asociados según versión de integración elegida.

### Flujo sugerido
1. Verificar disponibilidad de Health Connect.
2. Solicitar permisos granulares por métrica.
3. Leer registros por rango temporal (`start/end`).
4. Mapear a modelos internos (`HealthDataBundle`).

### Límites/consideraciones
- El usuario puede revocar permisos en cualquier momento.
- Algunas fuentes entregan datos agregados y otras por muestras.
- Diferencias de huso horario y duplicados entre fuentes deben normalizarse.

## iOS — HealthKit (guía)

### Requisitos
- Activar capability **HealthKit** en el target iOS.
- Definir descripciones de uso en `Info.plist` (mensajes claros para el usuario).

### Flujo sugerido
1. Consultar disponibilidad de HealthKit.
2. Solicitar permisos de lectura por tipo (steps, body mass, active energy/minutes según modelo).
3. Leer muestras/estadísticas en ventana temporal.
4. Convertir a modelos internos.

### Límites/consideraciones
- Permisos son estrictamente por tipo de dato.
- HealthKit puede no tener datos para ciertos periodos.
- No asumir paridad exacta de tipos entre iOS y Android.

## Contrato wire esperado para MethodChannel (propuesta)

### Canal permisos: `nutri_fit/health_permissions`
- `getPermissionStatus({ metrics: ["steps", "weight", "activityMinutes"] })`
- `requestPermissions({ metrics: [...] })`

Respuesta (map):
```json
{
  "steps": "granted|denied|restricted|notDetermined|unsupported",
  "weight": "granted|denied|restricted|notDetermined|unsupported",
  "activityMinutes": "granted|denied|restricted|notDetermined|unsupported"
}
```

### Canal datos: `nutri_fit/health_data`
- `readHealthData({ start: "ISO-8601", end: "ISO-8601", metrics: [...] })`

Respuesta (map):
```json
{
  "steps": [{ "timestamp": "ISO-8601", "value": 1234, "source": "health_connect" }],
  "weights": [{ "timestamp": "ISO-8601", "value": 72.4, "source": "healthkit" }],
  "activities": [{ "timestamp": "ISO-8601", "value": 35, "source": "health_connect" }]
}
```

## TODOs para completar integración real
1. Implementar handlers nativos Android/iOS de ambos MethodChannels.
2. Conectar permisos reales por tipo de dato.
3. Ajustar equivalencias de actividad (minutos activos vs tipos disponibles por plataforma).
4. Añadir pruebas unitarias de mappers con payloads reales.
5. Añadir pruebas de integración con mocks de channel.
6. (Opcional) migrar adapter interno a plugin `health` manteniendo contratos.

## Buenas prácticas de producto y seguridad
- Mostrar consentimiento explícito y explicar para qué se usa cada métrica.
- Permitir uso de la app aunque el usuario no comparta datos de salud.
- Tratar datos de salud como sensibles (mínima retención y acceso restringido).
- En UX y textos: mantener enfoque wellness, no diagnóstico clínico.
