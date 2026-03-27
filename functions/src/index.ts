import { onCall, HttpsError } from 'firebase-functions/https';
import { logger } from 'firebase-functions';
import { initializeApp } from 'firebase-admin/app';
import { AI_COACH_PROVIDER, OPENAI_API_KEY, OPENAI_MODEL } from './config/env';
import { AppError } from './errors/appError';
import { buildCoachResponse } from './services/openai/aiCoachService';
import { validateAiCoachChatRequest } from './validation/aiChatValidator';

initializeApp();

export const aiCoachChat = onCall(
  {
    region: 'us-central1',
    timeoutSeconds: 30,
    memory: '512MiB',
    secrets: [OPENAI_API_KEY],
  },
  async (request) => {
    try {
      const payload = validateAiCoachChatRequest(request.data);

      const provider = AI_COACH_PROVIDER.value() as 'mock' | 'openai';
      const model = OPENAI_MODEL.value();
      const openAiApiKey = provider === 'openai' ? OPENAI_API_KEY.value() : undefined;

      return await buildCoachResponse(payload, {
        provider,
        model,
        openAiApiKey,
      });
    } catch (error) {
      if (error instanceof AppError) {
        throw error.toHttpsError();
      }

      logger.error('aiCoachChat unexpected error', error);
      if (error instanceof HttpsError) {
        throw error;
      }

      throw new HttpsError('internal', 'Unexpected error while processing AI coach request.');
    }
  },
);
