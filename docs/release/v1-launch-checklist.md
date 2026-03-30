# NutriFit V1 Launch Checklist (Android-first)

Estado: borrador operativo para preparar lanzamiento comercial inicial.
Última actualización: 2026-03-30.

## 0) Definición de alcance V1 (Go/No-Go)

- [ ] Confirmar alcance V1: tracking (nutrición, ejercicio, progreso) + AI text premium.
- [ ] Dejar voz como **no bloqueante** para V1 (feature flag o UX “próximamente”).
- [ ] Congelar cambios de producto (feature freeze) para fase de estabilización.
- [ ] Definir criterios de salida de closed testing (crash-free, bugs P0/P1, conversión de compra básica).

## 1) Android release build y AAB firmado

- [ ] Reemplazar `applicationId` temporal (`com.example.nutri_fit`) por ID definitivo de producción.
- [ ] Configurar firma release real (keystore + `key.properties` fuera de git).
- [ ] Eliminar uso de debug signing en release (`signingConfig = debug` no apto para producción).
- [ ] Definir `versionCode` y `versionName` para release candidate.
- [ ] Generar AAB: `flutter build appbundle --release`.
- [ ] Verificar AAB localmente (instalación/internal sharing) y smoke test final.

## 2) Firebase Blaze + backend IA

- [ ] Confirmar proyecto Firebase de producción (separado de dev/staging).
- [ ] Activar plan Blaze y presupuestos/alertas de gasto.
- [ ] Configurar Firebase Auth (proveedores permitidos, políticas antiabuso básicas).
- [ ] Configurar Firestore (reglas de seguridad mínimas por entorno).
- [ ] Desplegar Cloud Functions de producción con secretos (`OPENAI_API_KEY`) vía Secret Manager.
- [ ] Forzar provider IA en prod a OpenAI (no mock).
- [ ] Definir cuotas premium de IA y límites server-side por usuario.
- [ ] Añadir observabilidad: logs estructurados, alertas de error 5xx y latencia.

## 3) Auth / Firestore / backend IA (validación funcional)

- [ ] Flujo auth completo validado (register/login/logout/session restore).
- [ ] CRUD de nutrición/ejercicio/progreso validado con Firestore real.
- [ ] Endpoints IA solo con entitlement premium activo.
- [ ] Bloqueo de acceso IA en clientes no premium + CTA a paywall.
- [ ] Manejo de errores de OpenAI (timeouts, rate limits, fallbacks UX).

## 4) Google Play Billing (premium IA)

- [ ] Crear producto de suscripción (`nutrifit_ai_monthly_499`) y base plan activo.
- [ ] Implementar verificación real server-side con Google Play Developer API.
- [ ] Validar `packageName`, `productId` y `purchaseToken` en backend.
- [ ] Persistir estado de suscripción en backend como source of truth.
- [ ] Soportar restauración de compras y refresco de estado en app.
- [ ] Manejar cancelación, expiración, grace period y account hold.
- [ ] Configurar RTDN o job de reconciliación para cambios sin abrir app.

## 5) Legal y cumplimiento (mínimo comercial)

- [ ] Publicar Privacy Policy (URL pública estable).
- [ ] Publicar página de soporte/contacto (URL pública estable).
- [ ] Publicar página de eliminación de cuenta/datos (URL pública estable).
- [ ] Incluir disclaimer wellness/no medical diagnosis en app y legal pages.
- [ ] Alinear Data Safety en Play Console con datos realmente recolectados/procesados.

## 6) Play Console setup (publicación)

- [ ] Completar ficha de app (descripción, categoría, contacto, gráficos, ícono, screenshots).
- [ ] Completar Content Rating questionnaire.
- [ ] Completar Data Safety form.
- [ ] Configurar país/precio y disponibilidad.
- [ ] Configurar Payments Profile de Google Play.
- [ ] Crear track de closed testing (si cuenta nueva lo exige) + testers.
- [ ] Subir AAB firmado al track correcto.
- [ ] Resolver warnings/bloqueos pre-launch report.

## 7) Crash reporting / analytics / operación

- [ ] Integrar crash reporting (Crashlytics o equivalente).
- [ ] Definir eventos de analytics mínimos: registro, trial intent, compra, restauración, cancelación, uso IA.
- [ ] Dashboard operativo semanal: installs, DAU/WAU, conversion premium, churn inicial, costo IA por usuario premium.
- [ ] Runbook de incidentes para billing, backend IA y caídas críticas.

## 8) Checklist de salida (Ready for commercial launch)

Lanzamiento comercial V1 solo si:

- [ ] AAB firmado de producción publicado en Play track objetivo.
- [ ] Billing server-side verificado end-to-end (compra, renovación, cancelación).
- [ ] Páginas legales públicas enlazadas en Play y en app.
- [ ] Data Safety y Content Rating aprobados.
- [ ] Observabilidad activa con alertas y responsables.
- [ ] Sin blockers P0/P1 abiertos.
