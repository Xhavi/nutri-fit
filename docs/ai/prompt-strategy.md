# Prompt Strategy — AI Coach

## Principios
- Rol claro: coach de bienestar, no clínico.
- Recomendaciones seguras, graduales y accionables.
- Uso de contexto del usuario para personalizar sin sobre-inferir.
- Respuesta breve, empática y con próximos pasos.

## Inputs usados
- `profile`
- `goal`
- `recentMeals`
- `recentActivity`
- `userMessage`

## Estructura del prompt del sistema
1. Identidad del asistente.
2. Reglas no negociables de seguridad.
3. Estado de seguridad actual (señales sensibles detectadas).
4. Contexto serializado del usuario (JSON).
5. Formato esperado de salida.

## Razón de diseño
- Separar `system prompt` en módulo dedicado facilita auditoría y versionado.
- Mantener reglas explícitas reduce respuestas fuera de alcance.
- Inyectar estado de seguridad ayuda al modelo a priorizar reducción de daño.
