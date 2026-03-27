# AI Coach Backend Architecture (Serverless)

## Objetivo
Implementar un backend serverless para el chat del coach IA donde **la API key de OpenAI nunca vive en Flutter**.

## Decisión técnica
Se usa **Firebase Cloud Functions (2nd gen) con TypeScript** para alinearse con:
- Integración nativa ya existente con `cloud_functions` en la app.
- Menor fricción operativa para despliegue y observabilidad.
- Gestión de secretos vía Firebase/Google Secret Manager.

## Componentes
- `functions/src/index.ts`
  - Expone callable function `aiCoachChat`.
- `functions/src/contracts/aiChat.ts`
  - Contrato tipado request/response.
- `functions/src/validation/aiChatValidator.ts`
  - Validación de payload y límites de tamaño.
- `functions/src/prompts/systemPrompt.ts`
  - Construcción del prompt del sistema con contexto y reglas de seguridad.
- `functions/src/safety/safetyRules.ts`
  - Detección básica de señales sensibles + disclaimer.
- `functions/src/services/openai/*`
  - Adaptador a OpenAI Responses API y modo mock.
- `functions/src/config/env.ts`
  - Parámetros y secretos (`AI_COACH_PROVIDER`, `OPENAI_MODEL`, `OPENAI_API_KEY`).

## Flujo
1. Flutter llama `aiCoachChat` vía `httpsCallable`.
2. Backend valida request.
3. Backend detecta señales sensibles.
4. Backend construye system prompt robusto.
5. Backend ejecuta provider:
   - `mock` (por defecto, útil sin credenciales).
   - `openai` (requiere secreto).
6. Backend retorna respuesta estructurada y metadata de seguridad.

## Contrato (resumen)
### Request
```json
{
  "profile": { "dietaryPreferences": ["high-protein"] },
  "goal": { "primaryGoal": "fat-loss" },
  "recentMeals": [{ "summary": "Avena con yogurt" }],
  "recentActivity": [{ "summary": "Caminata 30 min" }],
  "userMessage": "¿Qué ceno hoy para cumplir mi objetivo?"
}
```

### Response
```json
{
  "assistantMessage": "...",
  "safety": {
    "containsSensitiveContent": false,
    "disclaimerShown": true,
    "escalationRecommended": false
  },
  "meta": {
    "model": "gpt-4.1-mini",
    "provider": "openai",
    "requestId": "..."
  }
}
```

## Activación de entorno real OpenAI
1. Configurar provider:
```bash
firebase functions:config:unset dummy # opcional, limpieza previa
firebase deploy --only functions
```
2. Definir parámetros/secreto (recomendado por consola Firebase o CLI):
```bash
firebase functions:secrets:set OPENAI_API_KEY
firebase functions:params:set AI_COACH_PROVIDER=openai
firebase functions:params:set OPENAI_MODEL=gpt-4.1-mini
```
3. Redeploy:
```bash
firebase deploy --only functions
```

Si `AI_COACH_PROVIDER=mock`, la función responde sin llamar OpenAI (útil en local/CI sin credenciales).
