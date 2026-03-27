import '../../domain/models/ai_coach_chat_models.dart';
import '../../domain/repositories/ai_coach_repository.dart';
import '../clients/ai_coach_api_client.dart';

class AiCoachRepositoryImpl implements AiCoachRepository {
  AiCoachRepositoryImpl({required AiCoachApiClient apiClient}) : _apiClient = apiClient;

  final AiCoachApiClient _apiClient;

  @override
  Future<AiCoachChatResponse> sendMessage(AiCoachChatRequest request) {
    return _apiClient.sendMessage(request);
  }
}
