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
import {
  assertAuthenticatedUser,
  getUserPlanStatus,
  registerFeatureUsage,
  validateFeatureAccess,
} from './services/billing/entitlementService';
import { FeatureKey } from './contracts/subscription';
import { NotImplementedPurchaseVerifier } from './services/billing/purchaseVerifier';
import { upsertSubscription } from './services/billing/subscriptionRepository';

initializeApp();

export const getPlanStatus = onCall(
  {
    region: 'us-central1',
    timeoutSeconds: 15,
    memory: '256MiB',
  },
  async (request) => {
    const userId = assertAuthenticatedUser(request.auth?.uid);
    return await getUserPlanStatus(userId);
  },
);

export const validatePremiumFeature = onCall(
  {
    region: 'us-central1',
    timeoutSeconds: 15,
    memory: '256MiB',
  },
  async (request) => {
    const userId = assertAuthenticatedUser(request.auth?.uid);
    const feature = request.data?.feature as FeatureKey;

    if (feature !== 'ai_chat' && feature !== 'ai_voice') {
      throw new HttpsError('invalid-argument', 'Feature must be ai_chat or ai_voice.');
    }

    return await validateFeatureAccess(userId, feature);
  },
);

export const registerAiUsage = onCall(
  {
    region: 'us-central1',
    timeoutSeconds: 15,
    memory: '256MiB',
  },
  async (request) => {
    const userId = assertAuthenticatedUser(request.auth?.uid);
    const feature = request.data?.feature as FeatureKey;
    const amount = Number(request.data?.amount ?? 1);

    if (feature !== 'ai_chat' && feature !== 'ai_voice') {
      throw new HttpsError('invalid-argument', 'Feature must be ai_chat or ai_voice.');
    }

    return await registerFeatureUsage(userId, feature, amount);
  },
);

export const getRemainingQuota = onCall(
  {
    region: 'us-central1',
    timeoutSeconds: 15,
    memory: '256MiB',
  },
  async (request) => {
    const userId = assertAuthenticatedUser(request.auth?.uid);
    const feature = request.data?.feature as FeatureKey;

    if (feature !== 'ai_chat' && feature !== 'ai_voice') {
      throw new HttpsError('invalid-argument', 'Feature must be ai_chat or ai_voice.');
    }

    return await validateFeatureAccess(userId, feature);
  },
);

export const syncSubscriptionPurchase = onCall(
  {
    region: 'us-central1',
    timeoutSeconds: 30,
    memory: '256MiB',
  },
  async (request) => {
    const userId = assertAuthenticatedUser(request.auth?.uid);
    const provider = request.data?.provider as 'app_store' | 'play_store' | 'stripe';
    const receiptToken = request.data?.receiptToken as string;

    if (!provider || !receiptToken) {
      throw new HttpsError('invalid-argument', 'provider and receiptToken are required.');
    }

    const verifier = new NotImplementedPurchaseVerifier();

    try {
      const verified = await verifier.verify({
        provider,
        receiptToken,
        userId,
      });

      return await upsertSubscription(userId, {
        planId: verified.planId,
        status: verified.status,
        provider,
        providerSubscriptionId: verified.providerSubscriptionId,
        currentPeriodStartAt: verified.currentPeriodStartAt,
        currentPeriodEndAt: verified.currentPeriodEndAt,
      });
    } catch (error) {
      logger.warn('syncSubscriptionPurchase adapter not ready', { provider, userId, error });
      throw new HttpsError('failed-precondition', 'Purchase verification adapter is not configured yet.');
    }
  },
);

export const aiCoachChat = onCall(
  {
    region: 'us-central1',
    timeoutSeconds: 30,
    memory: '512MiB',
    secrets: [OPENAI_API_KEY],
  },
  async (request) => {
    try {
      const userId = assertAuthenticatedUser(request.auth?.uid);
      const access = await validateFeatureAccess(userId, 'ai_chat');
      if (!access.allowed) {
        throw new HttpsError('permission-denied', `AI chat blocked: ${access.reason ?? 'not_allowed'}`);
      }

      const payload = validateAiCoachChatRequest(request.data);

      const provider = AI_COACH_PROVIDER.value() as 'mock' | 'openai';
      const model = OPENAI_MODEL.value();
      const openAiApiKey = provider === 'openai' ? OPENAI_API_KEY.value() : undefined;

      const response = await buildCoachResponse(payload, {
        provider,
        model,
        openAiApiKey,
      });

      await registerFeatureUsage(userId, 'ai_chat', 1);
      return response;
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
      const userId = assertAuthenticatedUser(request.auth?.uid);
      const access = await validateFeatureAccess(userId, 'ai_voice');
      if (!access.allowed) {
        throw new HttpsError('permission-denied', `AI voice blocked: ${access.reason ?? 'not_allowed'}`);
      }

      const payload = validateVoiceTurnRequest(request.data);

      const provider = AI_VOICE_PROVIDER.value() as 'mock' | 'openai';
      const openAiApiKey = provider === 'openai' ? OPENAI_API_KEY.value() : undefined;

      const result = await processVoiceTurn(payload, {
        provider,
        openAiApiKey,
        coachModel: OPENAI_MODEL.value(),
        transcriptionModel: OPENAI_TRANSCRIPTION_MODEL.value(),
        ttsModel: OPENAI_TTS_MODEL.value(),
        defaultVoice: OPENAI_TTS_DEFAULT_VOICE.value(),
      });

      await registerFeatureUsage(userId, 'ai_voice', 1);
      return result;
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
