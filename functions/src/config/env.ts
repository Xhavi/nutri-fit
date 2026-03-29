import { defineString, defineSecret } from 'firebase-functions/params';

export const AI_COACH_PROVIDER = defineString('AI_COACH_PROVIDER', {
  default: 'mock',
  input: {
    text: {
      validationRegex: '^(mock|openai)$',
      validationErrorMessage: 'AI_COACH_PROVIDER must be mock or openai.',
    },
  },
});

export const OPENAI_MODEL = defineString('OPENAI_MODEL', {
  default: 'gpt-4.1-mini',
});

export const OPENAI_API_KEY = defineSecret('OPENAI_API_KEY');

export const AI_VOICE_PROVIDER = defineString('AI_VOICE_PROVIDER', {
  default: 'mock',
  input: {
    text: {
      validationRegex: '^(mock|openai)$',
      validationErrorMessage: 'AI_VOICE_PROVIDER must be mock or openai.',
    },
  },
});

export const OPENAI_TRANSCRIPTION_MODEL = defineString('OPENAI_TRANSCRIPTION_MODEL', {
  default: 'gpt-4o-mini-transcribe',
});

export const OPENAI_TTS_MODEL = defineString('OPENAI_TTS_MODEL', {
  default: 'gpt-4o-mini-tts',
});

export const OPENAI_TTS_DEFAULT_VOICE = defineString('OPENAI_TTS_DEFAULT_VOICE', {
  default: 'alloy',
});
