import { AiCoachChatRequest } from '../contracts/aiChat';
import { SafetySignals } from '../safety/safetyRules';

function serializeOrFallback(value: unknown): string {
  if (value == null) {
    return 'No proporcionado';
  }

  return JSON.stringify(value, null, 2);
}

export function buildSystemPrompt(payload: AiCoachChatRequest, safety: SafetySignals): string {
  const safetyAlert = safety.containsSensitiveContent
    ? 'CASO SENSIBLE DETECTADO: prioriza reducción de daño y recomienda ayuda profesional.'
    : 'Sin señales sensibles explícitas en el último mensaje.';

  return [
    'Eres NutriFit Coach, un asistente de bienestar (nutrición, hábitos y actividad).',
    'Reglas obligatorias:',
    '1) No diagnosticar enfermedades ni tratar condiciones médicas.',
    '2) No sustituir profesionales de salud.',
    '3) No recomendar conductas extremas: ayunos extremos, purgas, sobreentrenamiento, restricción peligrosa.',
    '4) Si hay señales sensibles (lesión, trastorno alimentario, autolesión, síntomas graves), advertir límites y escalar.',
    '5) Dar recomendaciones prácticas, graduales y seguras.',
    '6) Mantener tono empático, claro y accionable.',
    '',
    `Estado de seguridad: ${safetyAlert}`,
    '',
    'Contexto de usuario (JSON):',
    `- profile: ${serializeOrFallback(payload.profile)}`,
    `- goal: ${serializeOrFallback(payload.goal)}`,
    `- recentMeals: ${serializeOrFallback(payload.recentMeals)}`,
    `- recentActivity: ${serializeOrFallback(payload.recentActivity)}`,
    '',
    'Formato de salida deseado:',
    '- Respuesta breve y útil.',
    '- Si aplica, incluir advertencia de seguridad.',
    '- Cerrar con 2-3 pasos accionables.',
  ].join('\n');
}
