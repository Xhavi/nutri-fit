import { onCall, HttpsError } from 'firebase-functions/https';
import { logger } from 'firebase-functions';
import { initializeApp } from 'firebase-admin/app';
import {
  AI_COACH_PROVIDER,
  OPENAI_API_KEY,
  OPENAI_MODEL,
  AI_VOICE_PROVIDER,
  OPENAI_TRANSCRIPTION_MODEL,
  OPENAI_TTS_MODEL,
  OPENAI_TTS_DEFAULT_VOICE,
} from './config/env';
import { AppError } from './errors/appError';
import { buildCoachResponse } from './services/openai/aiCoachService';
import { validateAiCoachChatRequest } from './validation/aiChatValidator';
import { validateVoiceTurnRequest } from './validation/voiceTurnValidator';
import { processVoiceTurn } from './services/openai/voiceTurnService';

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

export const voiceTurn = onCall(
  {
    region: 'us-central1',
    timeoutSeconds: 60,
    memory: '1GiB',
    secrets: [OPENAI_API_KEY],
  },
  async (request) => {
    try {
      const payload = validateVoiceTurnRequest(request.data);

      const provider = AI_VOICE_PROVIDER.value() as 'mock' | 'openai';
      const openAiApiKey = provider === 'openai' ? OPENAI_API_KEY.value() : undefined;

      return await processVoiceTurn(payload, {
        provider,
        openAiApiKey,
        coachModel: OPENAI_MODEL.value(),
        transcriptionModel: OPENAI_TRANSCRIPTION_MODEL.value(),
        ttsModel: OPENAI_TTS_MODEL.value(),
        defaultVoice: OPENAI_TTS_DEFAULT_VOICE.value(),
      });
    } catch (error) {
      if (error instanceof AppError) {
        throw error.toHttpsError();
      }

      logger.error('voiceTurn unexpected error', error);
      if (error instanceof HttpsError) {
        throw error;
      }

      throw new HttpsError('internal', 'Unexpected error while processing voice turn.');
    }
  },
);
