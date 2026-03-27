export interface UserProfileContext {
  age?: number;
  sex?: 'female' | 'male' | 'other' | 'prefer_not_to_say';
  heightCm?: number;
  weightKg?: number;
  dietaryPreferences?: string[];
  allergies?: string[];
  medicalNotes?: string[];
}

export interface GoalContext {
  primaryGoal: string;
  targetDateIso?: string;
  notes?: string;
}

export interface MealContextItem {
  eatenAtIso?: string;
  summary: string;
  estimatedCalories?: number;
}

export interface ActivityContextItem {
  occurredAtIso?: string;
  summary: string;
  durationMinutes?: number;
  intensity?: 'low' | 'medium' | 'high';
}

export interface AiCoachChatRequest {
  profile?: UserProfileContext;
  goal?: GoalContext;
  recentMeals?: MealContextItem[];
  recentActivity?: ActivityContextItem[];
  userMessage: string;
}

export interface AiCoachSafetyMetadata {
  containsSensitiveContent: boolean;
  disclaimerShown: boolean;
  escalationRecommended: boolean;
}

export interface AiCoachChatResponse {
  assistantMessage: string;
  safety: AiCoachSafetyMetadata;
  meta: {
    model: string;
    provider: 'openai' | 'mock';
    requestId: string;
  };
}
