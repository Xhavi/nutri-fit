import { AiCoachChatRequest } from '../contracts/aiChat';
import { AppError } from '../errors/appError';

const MAX_USER_MESSAGE_LENGTH = 3000;
const MAX_LIST_ITEMS = 30;

function assertOptionalStringArray(value: unknown, fieldName: string): void {
  if (value == null) {
    return;
  }

  if (!Array.isArray(value) || value.some((item) => typeof item !== 'string')) {
    throw new AppError('invalid-argument', `${fieldName} must be an array of strings.`);
  }
}

export function validateAiCoachChatRequest(input: unknown): AiCoachChatRequest {
  if (!input || typeof input !== 'object' || Array.isArray(input)) {
    throw new AppError('invalid-argument', 'Payload must be an object.');
  }

  const payload = input as Record<string, unknown>;

  if (typeof payload.userMessage !== 'string' || payload.userMessage.trim().length === 0) {
    throw new AppError('invalid-argument', 'userMessage is required and must be a non-empty string.');
  }

  if (payload.userMessage.length > MAX_USER_MESSAGE_LENGTH) {
    throw new AppError('invalid-argument', `userMessage exceeds ${MAX_USER_MESSAGE_LENGTH} characters.`);
  }

  if (payload.recentMeals != null && (!Array.isArray(payload.recentMeals) || payload.recentMeals.length > MAX_LIST_ITEMS)) {
    throw new AppError('invalid-argument', `recentMeals must be an array with up to ${MAX_LIST_ITEMS} items.`);
  }

  if (
    payload.recentActivity != null &&
    (!Array.isArray(payload.recentActivity) || payload.recentActivity.length > MAX_LIST_ITEMS)
  ) {
    throw new AppError('invalid-argument', `recentActivity must be an array with up to ${MAX_LIST_ITEMS} items.`);
  }

  if (payload.profile != null) {
    if (typeof payload.profile !== 'object' || Array.isArray(payload.profile)) {
      throw new AppError('invalid-argument', 'profile must be an object.');
    }

    const profile = payload.profile as Record<string, unknown>;
    assertOptionalStringArray(profile.dietaryPreferences, 'profile.dietaryPreferences');
    assertOptionalStringArray(profile.allergies, 'profile.allergies');
    assertOptionalStringArray(profile.medicalNotes, 'profile.medicalNotes');
  }

  if (payload.goal != null && (typeof payload.goal !== 'object' || Array.isArray(payload.goal))) {
    throw new AppError('invalid-argument', 'goal must be an object.');
  }

  return {
    profile: payload.profile as AiCoachChatRequest['profile'],
    goal: payload.goal as AiCoachChatRequest['goal'],
    recentMeals: payload.recentMeals as AiCoachChatRequest['recentMeals'],
    recentActivity: payload.recentActivity as AiCoachChatRequest['recentActivity'],
    userMessage: payload.userMessage.trim(),
  };
}
