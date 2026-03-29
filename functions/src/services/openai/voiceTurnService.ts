import { VoiceTurnRequest, VoiceTurnResponse } from '../../contracts/voiceTurn';
import { transcribeUserAudio } from './transcriptionService';
import { generateCoachVoiceResponse } from './voiceCoachResponseService';
import { synthesizeCoachSpeech } from './speechSynthesisService';

export interface VoiceTurnConfig {
  provider: 'mock' | 'openai';
  openAiApiKey?: string;
  coachModel: string;
  transcriptionModel: string;
  ttsModel: string;
  defaultVoice: string;
}

export async function processVoiceTurn(
  payload: VoiceTurnRequest,
  config: VoiceTurnConfig,
): Promise<VoiceTurnResponse> {
  const audioBytes = Buffer.from(payload.audio.base64, 'base64');

  const transcription = await transcribeUserAudio(
    {
      audioBytes,
      mimeType: payload.audio.mimeType,
      filename: payload.audio.filename,
    },
    {
      provider: config.provider,
      apiKey: config.openAiApiKey,
      model: config.transcriptionModel,
    },
  );

  const coach = await generateCoachVoiceResponse(transcription.transcript, payload, {
    provider: config.provider,
    model: config.coachModel,
    openAiApiKey: config.openAiApiKey,
  });

  const tts = await synthesizeCoachSpeech(
    {
      text: coach.assistantMessage,
      format: payload.voice?.format ?? 'mp3',
      voiceProfileId: payload.voice?.profileId ?? config.defaultVoice,
      styleInstructions: payload.voice?.styleInstructions,
      intent: payload.voice?.intent,
      rate: payload.voice?.rate,
    },
    {
      provider: config.provider,
      apiKey: config.openAiApiKey,
      model: config.ttsModel,
      defaultVoice: config.defaultVoice,
    },
  );

  return {
    userTranscript: transcription.transcript,
    assistantText: coach.assistantMessage,
    assistantAudio: {
      base64: tts.audioBase64,
      mimeType: tts.mimeType,
    },
    voiceProfileUsed: tts.voiceProfileUsed,
    safety: coach.safety,
    meta: {
      provider: config.provider,
      requestId: coach.meta.requestId,
      model: config.coachModel,
      transcriptionModel: transcription.model,
      ttsModel: tts.model,
      locale: payload.metadata?.locale,
    },
  };
}
