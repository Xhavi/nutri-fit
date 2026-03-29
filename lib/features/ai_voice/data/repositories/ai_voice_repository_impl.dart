import '../../domain/models/voice_turn_models.dart';
import '../../domain/repositories/ai_voice_repository.dart';
import '../clients/ai_voice_api_client.dart';

class AiVoiceRepositoryImpl implements AiVoiceRepository {
  AiVoiceRepositoryImpl({required AiVoiceApiClient apiClient}) : _apiClient = apiClient;

  final AiVoiceApiClient _apiClient;

  @override
  Future<VoiceTurnResponse> sendVoiceTurn(VoiceTurnRequest request) {
    return _apiClient.sendVoiceTurn(request);
  }
}
