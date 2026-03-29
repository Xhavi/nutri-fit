import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/functions/functions_service.dart';
import '../../domain/models/voice_turn_models.dart';
import 'ai_voice_api_client.dart';

class FirebaseAiVoiceApiClient implements AiVoiceApiClient {
  FirebaseAiVoiceApiClient({required FunctionsService functionsService})
    : _functionsService = functionsService;

  final FunctionsService _functionsService;

  @override
  Future<VoiceTurnResponse> sendVoiceTurn(VoiceTurnRequest request) async {
    final Map<String, dynamic>? response = await _functionsService.call(
      'aiVoiceTurn',
      payload: request.toJson(),
    );

    if (response == null) {
      throw AppException('El backend de voz devolvió una respuesta vacía.');
    }

    return VoiceTurnResponse.fromJson(response);
  }
}
