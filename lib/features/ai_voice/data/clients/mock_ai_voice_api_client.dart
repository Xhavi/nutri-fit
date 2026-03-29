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
          'Mock voice response: entendí "$userText". TODO(V1): conectar backend real por turnos.',
      outputAudio: const <int>[],
      outputAudioMimeType: 'audio/mpeg',
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
}
