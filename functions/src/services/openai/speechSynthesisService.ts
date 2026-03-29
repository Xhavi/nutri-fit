import { randomUUID } from 'node:crypto';
import { AppError } from '../../errors/appError';
import { createOpenAiClient } from './openaiClient';

export interface SpeechSynthesisConfig {
  provider: 'mock' | 'openai';
  apiKey?: string;
  model: string;
  defaultVoice: string;
}

export interface SpeechSynthesisInput {
  text: string;
  format: 'mp3' | 'wav';
  voiceProfileId: string;
  styleInstructions?: string;
  rate?: number;
  intent?: string;
}

export interface SpeechSynthesisOutput {
  audioBase64: string;
  mimeType: string;
  requestId: string;
  model: string;
  provider: 'openai' | 'mock';
  voiceProfileUsed: string;
}

export async function synthesizeCoachSpeech(
  input: SpeechSynthesisInput,
  config: SpeechSynthesisConfig,
): Promise<SpeechSynthesisOutput> {
  if (config.provider === 'mock') {
    return {
      audioBase64: Buffer.from(`mock-audio:${input.text}`).toString('base64'),
      mimeType: mapMimeType(input.format),
      requestId: randomUUID(),
      model: 'mock-tts-v1',
      provider: 'mock',
      voiceProfileUsed: input.voiceProfileId || config.defaultVoice,
    };
  }

  if (!config.apiKey) {
    throw new AppError('failed-precondition', 'OPENAI_API_KEY is required for speech synthesis.');
  }

  const client = createOpenAiClient(config.apiKey);
  const selectedVoice = input.voiceProfileId || config.defaultVoice;
  const expressiveInstructions = buildExpressiveInstructions(input);

  const response = await client.audio.speech.create({
    model: config.model,
    voice: selectedVoice,
    input: input.text,
    response_format: input.format,
    ...(expressiveInstructions ? ({ instructions: expressiveInstructions } as Record<string, unknown>) : {}),
  } as any);

  const audioBuffer = Buffer.from(await response.arrayBuffer());

  return {
    audioBase64: audioBuffer.toString('base64'),
    mimeType: mapMimeType(input.format),
    requestId: randomUUID(),
    model: config.model,
    provider: 'openai',
    voiceProfileUsed: selectedVoice,
  };
}

function mapMimeType(format: 'mp3' | 'wav'): string {
  return format === 'wav' ? 'audio/wav' : 'audio/mpeg';
}

function buildExpressiveInstructions(input: SpeechSynthesisInput): string | undefined {
  const directives: string[] = [];
  if (input.styleInstructions && input.styleInstructions.trim().length > 0) {
    directives.push(input.styleInstructions.trim());
  }
  if (input.intent && input.intent.trim().length > 0) {
    directives.push(`Intent: ${input.intent.trim()}.`);
  }
  if (typeof input.rate === 'number') {
    directives.push(`Target pace factor: ${input.rate.toFixed(2)} (1.00 = neutral).`);
  }

  if (directives.length === 0) {
    return undefined;
  }

  return directives.join(' ');
}
