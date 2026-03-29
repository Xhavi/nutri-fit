import '../../domain/models/voice_turn_models.dart';

abstract class AiVoiceApiClient {
  Future<VoiceTurnResponse> sendVoiceTurn(VoiceTurnRequest request);
}
