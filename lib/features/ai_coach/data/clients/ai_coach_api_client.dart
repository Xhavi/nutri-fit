import '../../domain/models/ai_coach_chat_models.dart';

abstract class AiCoachApiClient {
  Future<AiCoachChatResponse> sendMessage(AiCoachChatRequest request);
}
