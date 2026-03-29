import { randomUUID } from 'node:crypto';
import { AppError } from '../../errors/appError';
import { toFile } from 'openai/uploads';
import { createOpenAiClient } from './openaiClient';

export interface TranscriptionConfig {
  provider: 'mock' | 'openai';
  apiKey?: string;
  model: string;
}

export interface TranscriptionInput {
  audioBytes: Buffer;
  mimeType: string;
  filename?: string;
}

export interface TranscriptionResult {
  transcript: string;
  requestId: string;
  model: string;
  provider: 'mock' | 'openai';
}

export async function transcribeUserAudio(
  input: TranscriptionInput,
  config: TranscriptionConfig,
): Promise<TranscriptionResult> {
  if (config.provider === 'mock') {
    return {
      transcript: 'Modo mock: transcripción simulada de audio del usuario.',
      requestId: randomUUID(),
      model: 'mock-transcription-v1',
      provider: 'mock',
    };
  }

  if (!config.apiKey) {
    throw new AppError('failed-precondition', 'OPENAI_API_KEY is required for voice transcription.');
  }

  const client = createOpenAiClient(config.apiKey);
  const file = await toFile(input.audioBytes, input.filename ?? `voice-input.${inferExt(input.mimeType)}`, {
    type: input.mimeType,
  });

  const response = await client.audio.transcriptions.create({
    file,
    model: config.model,
  });

  const transcript = typeof response.text === 'string' ? response.text.trim() : '';

  if (!transcript) {
    throw new AppError('internal', 'Transcription response was empty.');
  }

  return {
    transcript,
    requestId: randomUUID(),
    model: config.model,
    provider: 'openai',
  };
}

function inferExt(mimeType: string): string {
  if (mimeType.includes('webm')) return 'webm';
  if (mimeType.includes('wav')) return 'wav';
  if (mimeType.includes('ogg')) return 'ogg';
  if (mimeType.includes('mp4') || mimeType.includes('m4a')) return 'm4a';
  if (mimeType.includes('mpeg') || mimeType.includes('mp3')) return 'mp3';
  return 'bin';
}
