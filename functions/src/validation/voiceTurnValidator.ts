import { AppError } from '../errors/appError';
import { VoiceTurnRequest } from '../contracts/voiceTurn';

const MAX_AUDIO_BASE64_CHARS = 15_000_000;
const MAX_RECENT_TURNS = 6;

function validateString(value: unknown, field: string): string {
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new AppError('invalid-argument', `${field} must be a non-empty string.`);
  }

  return value.trim();
}

export function validateVoiceTurnRequest(input: unknown): VoiceTurnRequest {
  if (!input || typeof input !== 'object' || Array.isArray(input)) {
    throw new AppError('invalid-argument', 'Payload must be an object.');
  }

  const payload = input as Record<string, unknown>;

  if (!payload.audio || typeof payload.audio !== 'object' || Array.isArray(payload.audio)) {
    throw new AppError('invalid-argument', 'audio is required and must be an object.');
  }

  const audio = payload.audio as Record<string, unknown>;
  const audioBase64 = validateString(audio.base64, 'audio.base64');
  const audioMimeType = validateString(audio.mimeType, 'audio.mimeType');

  if (audioBase64.length > MAX_AUDIO_BASE64_CHARS) {
    throw new AppError('invalid-argument', `audio.base64 exceeds ${MAX_AUDIO_BASE64_CHARS} characters.`);
  }

  const conversationRaw = payload.conversation as Record<string, unknown> | undefined;
  if (conversationRaw?.recentTurns != null) {
    if (!Array.isArray(conversationRaw.recentTurns)) {
      throw new AppError('invalid-argument', 'conversation.recentTurns must be an array.');
    }

    if (conversationRaw.recentTurns.length > MAX_RECENT_TURNS) {
      throw new AppError('invalid-argument', `conversation.recentTurns must contain up to ${MAX_RECENT_TURNS} items.`);
    }

    conversationRaw.recentTurns.forEach((turn, index) => {
      if (!turn || typeof turn !== 'object' || Array.isArray(turn)) {
        throw new AppError('invalid-argument', `conversation.recentTurns[${index}] must be an object.`);
      }

      const row = turn as Record<string, unknown>;
      validateString(row.userText, `conversation.recentTurns[${index}].userText`);
      validateString(row.assistantText, `conversation.recentTurns[${index}].assistantText`);
    });
  }

  const voiceRaw = payload.voice as Record<string, unknown> | undefined;
  if (voiceRaw?.format != null && voiceRaw.format !== 'mp3' && voiceRaw.format !== 'wav') {
    throw new AppError('invalid-argument', 'voice.format must be mp3 or wav.');
  }
  if (voiceRaw?.styleInstructions != null && typeof voiceRaw.styleInstructions !== 'string') {
    throw new AppError('invalid-argument', 'voice.styleInstructions must be a string.');
  }
  if (voiceRaw?.intent != null && typeof voiceRaw.intent !== 'string') {
    throw new AppError('invalid-argument', 'voice.intent must be a string.');
  }
  if (
    voiceRaw?.rate != null &&
    (typeof voiceRaw.rate !== 'number' || Number.isNaN(voiceRaw.rate) || voiceRaw.rate <= 0)
  ) {
    throw new AppError('invalid-argument', 'voice.rate must be a positive number.');
  }

  return {
    audio: {
      base64: audioBase64,
      mimeType: audioMimeType,
      filename: typeof audio.filename === 'string' ? audio.filename : undefined,
    },
    metadata: payload.metadata as VoiceTurnRequest['metadata'],
    context: payload.context as VoiceTurnRequest['context'],
    conversation: payload.conversation as VoiceTurnRequest['conversation'],
    voice: {
      format: (voiceRaw?.format as 'mp3' | 'wav' | undefined) ?? 'mp3',
      profileId: typeof voiceRaw?.profileId === 'string' ? voiceRaw.profileId : 'coach_default',
      styleInstructions:
        typeof voiceRaw?.styleInstructions === 'string' ? voiceRaw.styleInstructions : undefined,
      intent: typeof voiceRaw?.intent === 'string' ? voiceRaw.intent : undefined,
      rate: typeof voiceRaw?.rate === 'number' ? voiceRaw.rate : undefined,
    },
  };
}
