import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/functions/functions_service.dart';
import '../../domain/models/ai_coach_chat_models.dart';
import 'ai_coach_api_client.dart';

class FirebaseAiCoachApiClient implements AiCoachApiClient {
  FirebaseAiCoachApiClient({required FunctionsService functionsService})
    : _functionsService = functionsService;

  final FunctionsService _functionsService;

  @override
  Future<AiCoachChatResponse> sendMessage(AiCoachChatRequest request) async {
    final Map<String, dynamic>? response = await _functionsService.call(
      'aiCoachChat',
      payload: request.toJson(),
    );

    if (response == null) {
      throw AppException('El backend de AI Coach devolvió una respuesta vacía.');
    }

    return AiCoachChatResponse.fromJson(response);
  }
}
