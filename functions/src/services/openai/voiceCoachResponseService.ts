import { AiCoachChatRequest, AiCoachChatResponse } from '../../contracts/aiChat';
import { VoiceTurnRequest } from '../../contracts/voiceTurn';
import { buildCoachResponse } from './aiCoachService';

export interface VoiceCoachConfig {
  provider: 'mock' | 'openai';
  model: string;
  openAiApiKey?: string;
}

export async function generateCoachVoiceResponse(
  transcript: string,
  payload: VoiceTurnRequest,
  config: VoiceCoachConfig,
): Promise<AiCoachChatResponse> {
  const coachRequest: AiCoachChatRequest = {
    userMessage: transcript,
    profile: payload.context?.profile,
    goal: payload.context?.goal,
    recentMeals: payload.context?.recentMeals,
    recentActivity: payload.context?.recentActivity,
  };

  return buildCoachResponse(coachRequest, config);
}
