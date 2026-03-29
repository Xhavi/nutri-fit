import '../../domain/models/transcription_result.dart';
import '../../domain/models/voice_turn_models.dart';
import 'ai_voice_api_client.dart';

class MockAiVoiceApiClient implements AiVoiceApiClient {
  @override
  Future<VoiceTurnResponse> sendVoiceTurn(VoiceTurnRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final String userText = (request.transcript == null || request.transcript!.trim().isEmpty)
        ? 'mensaje de voz'
        : request.transcript!.trim();

    return VoiceTurnResponse(
      assistantText:
          'Mock voice response: entendí "$userText". Recomendación breve: hidrátate y mantén una cena balanceada en proteína y fibra.',
      outputAudio: _buildSilentWavBytes(durationMs: 550),
      outputAudioMimeType: 'audio/wav',
      transcription: TranscriptionResult(
        text: userText,
        languageCode: request.locale ?? 'es',
        confidence: 0.8,
      ),
      metadata: const VoiceTurnMetadata(
        requestId: 'mock-request',
        provider: 'mock',
        model: 'mock-model',
        turnMode: 'ptt',
        latencyMs: 300,
      ),
    );
  }

  List<int> _buildSilentWavBytes({required int durationMs}) {
    const int sampleRate = 16000;
    const int channels = 1;
    const int bitsPerSample = 16;
    final int totalSamples = (sampleRate * durationMs) ~/ 1000;
    final int bytesPerSample = bitsPerSample ~/ 8;
    final int dataSize = totalSamples * channels * bytesPerSample;
    final int fileSize = 36 + dataSize;

    int offset = 0;
    final List<int> bytes = List<int>.filled(44 + dataSize, 0);

    void writeString(String value) {
      for (final int codeUnit in value.codeUnits) {
        bytes[offset++] = codeUnit;
      }
    }

    void writeUint32(int value) {
      bytes[offset++] = value & 0xFF;
      bytes[offset++] = (value >> 8) & 0xFF;
      bytes[offset++] = (value >> 16) & 0xFF;
      bytes[offset++] = (value >> 24) & 0xFF;
    }

    void writeUint16(int value) {
      bytes[offset++] = value & 0xFF;
      bytes[offset++] = (value >> 8) & 0xFF;
    }

    writeString('RIFF');
    writeUint32(fileSize);
    writeString('WAVE');
    writeString('fmt ');
    writeUint32(16);
    writeUint16(1);
    writeUint16(channels);
    writeUint32(sampleRate);
    writeUint32(sampleRate * channels * bytesPerSample);
    writeUint16(channels * bytesPerSample);
    writeUint16(bitsPerSample);
    writeString('data');
    writeUint32(dataSize);

    return bytes;
  }
}
