import '../models/ai_coach_chat_models.dart';

abstract class AiCoachRepository {
  Future<AiCoachChatResponse> sendMessage(AiCoachChatRequest request);
}
