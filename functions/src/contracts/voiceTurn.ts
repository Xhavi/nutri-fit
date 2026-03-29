import { ActivityContextItem, GoalContext, UserProfileContext, MealContextItem, AiCoachSafetyMetadata } from './aiChat';

export interface VoiceInputAudio {
  base64: string;
  mimeType: string;
  filename?: string;
}

export interface VoiceTurnMetadata {
  locale?: string;
  timezone?: string;
  appVersion?: string;
  platform?: string;
}

export interface ConversationTurn {
  userText: string;
  assistantText: string;
}

export interface VoiceConversationContext {
  conversationId?: string;
  recentTurns?: ConversationTurn[];
}

export interface VoiceOutputPreferences {
  profileId?: string;
  format?: 'mp3' | 'wav';
}

export interface VoiceTurnRequest {
  audio: VoiceInputAudio;
  metadata?: VoiceTurnMetadata;
  context?: {
    profile?: UserProfileContext;
    goal?: GoalContext;
    recentMeals?: MealContextItem[];
    recentActivity?: ActivityContextItem[];
  };
  conversation?: VoiceConversationContext;
  voice?: VoiceOutputPreferences;
}

export interface VoiceOutputAudio {
  base64: string;
  mimeType: string;
}

export interface VoiceTurnResponse {
  userTranscript: string;
  assistantText: string;
  assistantAudio: VoiceOutputAudio;
  voiceProfileUsed: string;
  safety: AiCoachSafetyMetadata;
  meta: {
    provider: 'openai' | 'mock';
    requestId: string;
    model: string;
    transcriptionModel: string;
    ttsModel: string;
    locale?: string;
  };
}
