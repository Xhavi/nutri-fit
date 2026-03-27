import 'package:uuid/uuid.dart';

import '../../domain/models/ai_coach_chat_models.dart';
import 'ai_coach_api_client.dart';

class MockAiCoachApiClient implements AiCoachApiClient {
  MockAiCoachApiClient();

  final Uuid _uuid = const Uuid();

  @override
  Future<AiCoachChatResponse> sendMessage(AiCoachChatRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final String responseText = _buildMockResponse(request.userMessage);
    return AiCoachChatResponse(
      assistantMessage: responseText,
      safety: AiCoachSafetyMetadata(
        containsSensitiveContent: _containsSensitiveTerms(request.userMessage),
        disclaimerShown: true,
        escalationRecommended: _containsSensitiveTerms(request.userMessage),
      ),
      meta: AiCoachChatMeta(
        model: 'mock-wellness-v1',
        provider: 'mock',
        requestId: _uuid.v4(),
      ),
    );
  }

  bool _containsSensitiveTerms(String input) {
    final String normalized = input.toLowerCase();
    return normalized.contains('dolor pecho') ||
        normalized.contains('desmayo') ||
        normalized.contains('autoles') ||
        normalized.contains('vomit');
  }

  String _buildMockResponse(String userMessage) {
    return 'Gracias por tu mensaje: "$userMessage". '
        'Como guía de bienestar, te sugiero priorizar una comida balanceada con proteína, '
        'vegetales y una porción moderada de carbohidratos. Si quieres, te propongo '
        'un plan de cena y desayuno según tu objetivo.';
  }
}
