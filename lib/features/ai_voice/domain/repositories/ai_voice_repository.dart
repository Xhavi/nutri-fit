import '../models/voice_turn_models.dart';

abstract class AiVoiceRepository {
  Future<VoiceTurnResponse> sendVoiceTurn(VoiceTurnRequest request);
}
