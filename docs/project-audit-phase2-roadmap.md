# Auditoría final del estado actual y propuesta de Fase 2 (NutriFit)

Fecha: 2026-03-29

## 1) Resumen ejecutivo

**Diagnóstico global:** la base es **sólida para iterar** (arquitectura feature-first, contratos por capa, guardrails de seguridad IA y CI), pero todavía está en estado **MVP scaffolding** con dependencia alta de mocks, datos de UI hardcodeados y varias piezas críticas pendientes para producción.

**Veredicto:**
- **Base técnica:** 7/10.
- **Listo para producción de negocio:** 4/10.
- **Listo para Fase 2 (si se ordena por prioridades):** 8/10.

---

## 2) Estado actual por dimensión

### Arquitectura y separación de capas

**Qué está bien**
- Estructura feature-first consistente (`presentation/domain/data`) y guía arquitectónica explícita.
- Uso de contratos e implementaciones separadas en auth, nutrición, ejercicio, AI coach y health integration.
- Bootstrap configurable por entorno y proveedor (Firebase/live vs mocks) sin exponer secretos en Flutter.

**Qué está regular**
- Hay mezcla de pantallas “demo” con datos fijos junto a flujos reales (auth/sesión), lo que dificulta leer madurez por feature.
- Parte de la lógica de orquestación vive en controladores grandes (p. ej. AI Coach controller), que crecerán rápido en Fase 2.

**Qué está mal o frágil**
- Repositorios críticos de producto aún son mock (nutrición/ejercicio), por lo que no existe persistencia real transversal.
- Contratos de meal planning/lista de compras existen, pero como placeholders sin implementación ni modelo de dominio útil.

---

### Mantenibilidad

**Qué está bien**
- Convenciones de linting y CI (analyze/test + build de functions) definidas.
- Tests unitarios en dominio/controladores/mappers para lógica central de MVP.
- Documentación base robusta (arquitectura, setup, IA, roadmap).

**Qué está regular**
- Cobertura de testing se concentra en unitarios; faltan tests de integración end-to-end entre app y backend.
- Falta observabilidad operativa (errores, trazas, eventos de producto con esquema estable).

**Qué está mal o frágil**
- `flutter` no está disponible en este entorno de auditoría, por lo que no se validó `flutter analyze`/`flutter test` aquí.

---

### Riesgos técnicos

1. **Riesgo de “falso positivo de avance”** por uso intensivo de mocks y dashboards hardcodeados.
2. **Riesgo de deuda de arquitectura** si Fase 2 agrega features sin consolidar persistencia y contratos primero.
3. **Riesgo de safety/regulatorio** por detección sensible aún basada en regex (baseline), sin clasificador ni protocolo por severidad.
4. **Riesgo de seguridad de datos** por almacenamiento local con `SharedPreferences` para datos de perfil/sesión sin cifrado adicional.
5. **Riesgo UX** por falta de notificaciones reales, estado offline/errores consistente y experiencia multi-rol (usuario/profesional).

---

### Gaps funcionales

- Recetas y meal planning: sin modelos/flujo end-to-end.
- Lista de compras: contrato vacío, sin UI ni motor de generación.
- Notificaciones: no hay sistema programado ni preferencias de frecuencia/canal.
- Panel profesional/nutricionista: inexistente (roles, permisos, vista clínica wellness).
- Pagos/suscripción: inexistente (planes, entitlement, paywall).
- Backend IA real: funciones listas en base, pero modo mock predomina y falta endurecimiento operativo.
- Analítica: sin plan de eventos instrumentado de punta a punta.

---

### Seguridad

**Fortalezas**
- API key de OpenAI queda en Functions (secreto), no en cliente Flutter.
- Validación de payload en backend IA y límites de longitud/listas.
- Guardrails explícitos de no diagnóstico y disclaimers.

**Debilidades**
- Falta política documentada de retención/anonimización para telemetría y chat.
- Falta cifrado local para datos sensibles de wellness/perfil.
- Falta estrategia de rate-limit y abuse prevention explícita por usuario/IP en la callable.

---

### Experiencia de usuario

**Qué está bien**
- Navegación principal clara y consistente.
- Mensajería de seguridad wellness bien visible en AI Coach.
- Flujos base de auth/onboarding/perfil ya conectados.

**Qué está regular**
- Varias secciones muestran datos estáticos, reduciendo confianza del usuario final.
- UX de error/reintento no está unificada en todas las features.

**Qué está mal o frágil**
- Splash indica TODO de inicialización real.
- Falta onboarding de permisos (salud/notificaciones) guiado por valor para el usuario.

---

## 3) Checklist de deuda técnica

- [ ] Reemplazar repositorios mock de nutrición y ejercicio por capa data real (Firestore/local sync).
- [ ] Definir modelos de dominio reales para recetas, plan semanal, ingredientes y lista de compras.
- [ ] Extraer casos de uso (use-cases) para reducir tamaño de controladores en presentation.
- [ ] Implementar estrategia de errores tipados transversal (domain/data/presentation).
- [ ] Agregar cifrado local para datos sensibles (perfil/objetivos/contexto IA).
- [ ] Endurecer backend IA: rate limiting, idempotencia, trazas estructuradas, circuit breakers.
- [ ] Migrar detección de seguridad IA de regex a pipeline por severidad + fallback seguro.
- [ ] Definir esquema de eventos de analítica versionado (tracking plan).
- [ ] Añadir tests de integración (app↔functions, repos↔storage, router↔session).
- [ ] Añadir smoke tests de release y checklist de observabilidad (errores, latencia, costo IA).

---

## 4) Checklist de producto

- [ ] Diseñar IA de recetas personalizadas (objetivo, restricciones, tiempo, presupuesto).
- [ ] Construir meal planner semanal editable + regeneración parcial de días.
- [ ] Generar lista de compras agrupada por categorías y consolidación de ingredientes.
- [ ] Notificaciones configurables (recordatorios comidas, agua, actividad, check-in semanal).
- [ ] Crear panel profesional con consentimiento explícito del usuario y acceso por rol.
- [ ] Definir monetización (free/pro) y límites por feature (mensajes IA, planes, panel pro).
- [ ] Integrar pasarela de pago y gestión de suscripciones multiplataforma.
- [ ] Activar backend IA en entorno real con políticas de seguridad y costo.
- [ ] Implementar analítica de producto (activación, retención, engagement, conversión).
- [ ] Definir métricas de éxito por feature con objetivos trimestrales.

---

## 5) Backlog priorizado (Fase 2)

## P0 — Fundaciones para escalar (2-4 semanas)
1. **Data real de tracking**: repositorios de nutrición/ejercicio en Firestore + cache local.
2. **Tracking plan analítico v1**: eventos clave y dashboard mínimo.
3. **Hardening IA backend v1**: rate limit, logging estructurado, alertas básicas de fallos/costo.
4. **Modelo de dominio Fase 2**: recetas, meal plans, grocery list y ownership multiusuario/pro.

## P1 — Valor directo al usuario final (4-8 semanas)
1. **Recetas + meal planning MVP**
   - recomendación de recetas
   - planner semanal editable
   - regeneración por restricciones/calorías
2. **Lista de compras MVP**
   - generación automática desde plan
   - check/uncheck, cantidades, categorías
   - “ya tengo en casa”
3. **Notificaciones inteligentes básicas**
   - recordatorios configurables
   - horarios por hábito
   - control de frecuencia (anti-fatiga)

## P2 — B2B2C y monetización (6-10 semanas)
1. **Panel profesional/nutricionista MVP**
   - acceso por invitación
   - vista de adherencia/resumen
   - recomendaciones asíncronas
2. **Pagos/suscripción**
   - planes Free/Pro
   - paywall contextual
   - control de entitlements

## P3 — IA y growth avanzados (continuo)
1. **Backend IA real production-grade**
   - policy engine de safety
   - memoria útil acotada
   - evaluación continua de calidad/respuesta segura
2. **Analítica avanzada**
   - cohortes, funnels, churn signals
   - experimentación A/B de prompts y UX

---

## 6) Recomendación de próximos 10 prompts

1. "Diseña el modelo de dominio Dart para Recipe, MealPlan, GroceryList con ejemplos JSON y validaciones."
2. "Propón contratos de repositorio + casos de uso para meal planning con arquitectura clean y Riverpod."
3. "Crea un tracking plan analítico v1 con eventos, propiedades, naming convention y ejemplos por pantalla."
4. "Diseña la estrategia de notificaciones: tipos, frecuencia, ventanas horarias y lógica anti-fatiga."
5. "Define un esquema de roles/permisos para panel profesional con consentimiento del usuario y auditoría."
6. "Propón arquitectura de suscripciones (free/pro), entitlements y puntos de paywall en la app."
7. "Genera un plan de hardening para aiCoachChat: rate limit, observabilidad, retries y costos."
8. "Diseña pruebas de integración críticas para auth, onboarding, nutrición, ejercicio y AI coach."
9. "Propón una UX flow completa para meal planning + lista de compras en 7 pasos con edge cases."
10. "Crea un plan de release de Fase 2 en sprints con definición de done, riesgos y mitigaciones."

---

## 7) Recomendación de ejecución de Fase 2 (orden sugerido)

1. **Primero P0** para evitar construir features sobre mocks.
2. **Luego P1** (recetas/planner/compras/notifs) para valor visible y retención.
3. **Después P2** (panel pro + monetización) cuando ya exista tracción de uso.
4. **Mantener P3 en paralelo liviano** con guardrails y medición continua.

Si se sigue este orden, NutriFit puede pasar de base MVP a plataforma escalable sin romper la arquitectura actual.
