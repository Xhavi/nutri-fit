import { randomUUID } from 'node:crypto';
import { AiCoachChatRequest, AiCoachChatResponse } from '../../contracts/aiChat';
import { AppError } from '../../errors/appError';
import { buildSystemPrompt } from '../../prompts/systemPrompt';
import { detectSafetySignals, safetyDisclaimerText } from '../../safety/safetyRules';
import { createOpenAiClient } from './openaiClient';

interface CoachServiceConfig {
  provider: 'mock' | 'openai';
  model: string;
  openAiApiKey?: string;
}

function ensureStringOutput(raw: unknown): string {
  if (typeof raw === 'string' && raw.trim().length > 0) {
    return raw.trim();
  }

  return 'No tengo suficiente información para responder con precisión. ¿Quieres que lo intentemos con más contexto?';
}

function buildMockResponse(request: AiCoachChatRequest): AiCoachChatResponse {
  const safety = detectSafetySignals(request.userMessage);
  const disclaimer = safetyDisclaimerText();

  return {
    assistantMessage: [
      'Modo mock activo (sin credenciales OpenAI).',
      'Te recomiendo priorizar una comida balanceada con proteína, fibra y buena hidratación hoy.',
      disclaimer,
    ].join(' '),
    safety: {
      containsSensitiveContent: safety.containsSensitiveContent,
      escalationRecommended: safety.escalationRecommended,
      disclaimerShown: true,
    },
    meta: {
      model: 'mock-coach-v1',
      provider: 'mock',
      requestId: randomUUID(),
    },
  };
}

export async function buildCoachResponse(
  request: AiCoachChatRequest,
  config: CoachServiceConfig,
): Promise<AiCoachChatResponse> {
  const safety = detectSafetySignals(request.userMessage);

  if (config.provider === 'mock') {
    return buildMockResponse(request);
  }

  if (!config.openAiApiKey) {
    throw new AppError('failed-precondition', 'OPENAI_API_KEY is required when AI_COACH_PROVIDER=openai.');
  }

  const client = createOpenAiClient(config.openAiApiKey);
  const systemPrompt = buildSystemPrompt(request, safety);

  const response = await client.responses.create({
    model: config.model,
    input: [
      {
        role: 'system',
        content: [{ type: 'input_text', text: systemPrompt }],
      },
      {
        role: 'user',
        content: [{ type: 'input_text', text: request.userMessage }],
      },
    ],
    temperature: 0.4,
  });

  const assistantMessage = ensureStringOutput(response.output_text);
  const disclaimer = safetyDisclaimerText();
  const shouldInjectDisclaimer = safety.containsSensitiveContent && !assistantMessage.includes(disclaimer);

  return {
    assistantMessage: shouldInjectDisclaimer ? `${assistantMessage}\n\n${disclaimer}` : assistantMessage,
    safety: {
      containsSensitiveContent: safety.containsSensitiveContent,
      escalationRecommended: safety.escalationRecommended,
      disclaimerShown: shouldInjectDisclaimer || assistantMessage.includes(disclaimer),
    },
    meta: {
      model: config.model,
      provider: 'openai',
      requestId: response.id ?? randomUUID(),
    },
  };
}
