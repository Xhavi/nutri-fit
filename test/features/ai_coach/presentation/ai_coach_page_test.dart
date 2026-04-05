import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/core/services/local_storage_service.dart';
import 'package:nutri_fit/features/ai_coach/domain/models/ai_coach_chat_models.dart';
import 'package:nutri_fit/features/ai_coach/domain/repositories/ai_coach_repository.dart';
import 'package:nutri_fit/features/ai_coach/presentation/controllers/ai_coach_controller.dart';
import 'package:nutri_fit/features/ai_coach/presentation/controllers/ai_coach_providers.dart';
import 'package:nutri_fit/features/ai_coach/presentation/pages/ai_coach_page.dart';
import 'package:nutri_fit/features/ai_voice/application/voice_turn_controller.dart';
import 'package:nutri_fit/features/ai_voice/domain/contracts/audio_player.dart';
import 'package:nutri_fit/features/ai_voice/domain/contracts/audio_recorder.dart';
import 'package:nutri_fit/features/ai_voice/domain/models/voice_turn_models.dart';
import 'package:nutri_fit/features/ai_voice/domain/repositories/ai_voice_repository.dart';
import 'package:nutri_fit/features/ai_voice/presentation/controllers/ai_voice_providers.dart';
import 'package:nutri_fit/features/auth/domain/session_state.dart';
import 'package:nutri_fit/features/exercise/presentation/controllers/exercise_state.dart';
import 'package:nutri_fit/features/nutrition/presentation/controllers/nutrition_state.dart';
import 'package:nutri_fit/features/profile/data/health_profile_repository.dart';
import 'package:nutri_fit/features/subscriptions/application/subscription_service.dart';
import 'package:nutri_fit/features/subscriptions/domain/models/entitlement_status.dart';
import 'package:nutri_fit/features/subscriptions/domain/models/subscription_plan.dart';
import 'package:nutri_fit/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:nutri_fit/features/subscriptions/presentation/controllers/subscription_controller.dart';
import 'package:nutri_fit/features/subscriptions/presentation/controllers/subscription_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AiCoachPage explains when the monthly chat quota is exhausted',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final subscriptionController = SubscriptionController(
      service: SubscriptionService(
        repository: _FakeSubscriptionRepository(
          status: const EntitlementStatus(
            tier: EntitlementTier.premiumAi,
            isActive: true,
            source: 'mock',
            featureAccess: <PremiumFeature, FeatureEntitlementStatus>{
              PremiumFeature.aiChat: FeatureEntitlementStatus(
                feature: PremiumFeature.aiChat,
                entitled: true,
                allowed: false,
                quota: 20,
                used: 20,
                remaining: 0,
                reason: 'monthly_quota_exceeded',
              ),
              PremiumFeature.aiVoice: FeatureEntitlementStatus(
                feature: PremiumFeature.aiVoice,
                entitled: true,
                allowed: true,
                quota: 60,
                used: 4,
                remaining: 56,
              ),
            },
          ),
        ),
      ),
    );
    await subscriptionController.initialize();

    final aiCoachController = AiCoachController(
      repository: _FakeAiCoachRepository(),
      profileRepository:
          HealthProfileRepository(localStorage: LocalStorageService()),
      getNutritionState: NutritionState.initial,
      getExerciseState: ExerciseState.initial,
      getSessionState: () => const SessionState(
        status: SessionStatus.authenticated,
        userId: 'qa-user',
      ),
      usesMockBackend: true,
    );

    final voiceTurnController = VoiceTurnController(
      repository: _FakeAiVoiceRepository(),
      recorder: _FakeAudioRecorder(),
      player: _FakeAudioPlayer(),
      localStorage: LocalStorageService(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          subscriptionControllerProvider
              .overrideWith((Ref ref) => subscriptionController),
          aiCoachControllerProvider
              .overrideWith((Ref ref) => aiCoachController),
          voiceTurnControllerProvider
              .overrideWith((Ref ref) => voiceTurnController),
        ],
        child: const MaterialApp(home: AiCoachPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Agotaste tu cuota mensual de chat IA. Puedes esperar la renovacion o revisar planes.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Agotaste tu cuota mensual de AI Coach. Puedes esperar la renovacion o revisar planes.',
      ),
      findsOneWidget,
    );

    expect(
        find.text(
            'Bloqueado: activa AI Premium para usar conversacion por voz.'),
        findsNothing);
  });

  testWidgets(
      'AiCoachPage explains when voice is blocked for the current state',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final subscriptionController = SubscriptionController(
      service: SubscriptionService(
        repository: _FakeSubscriptionRepository(
          status: const EntitlementStatus(
            tier: EntitlementTier.premiumAi,
            isActive: true,
            source: 'mock',
            featureAccess: <PremiumFeature, FeatureEntitlementStatus>{
              PremiumFeature.aiChat: FeatureEntitlementStatus(
                feature: PremiumFeature.aiChat,
                entitled: true,
                allowed: true,
                quota: 20,
                used: 2,
                remaining: 18,
              ),
              PremiumFeature.aiVoice: FeatureEntitlementStatus(
                feature: PremiumFeature.aiVoice,
                entitled: false,
                allowed: false,
                quota: 0,
                used: 0,
                remaining: 0,
                reason: 'feature_not_in_plan',
              ),
            },
          ),
        ),
      ),
    );
    await subscriptionController.initialize();

    final aiCoachController = AiCoachController(
      repository: _FakeAiCoachRepository(),
      profileRepository:
          HealthProfileRepository(localStorage: LocalStorageService()),
      getNutritionState: NutritionState.initial,
      getExerciseState: ExerciseState.initial,
      getSessionState: () => const SessionState(
        status: SessionStatus.authenticated,
        userId: 'qa-user',
      ),
      usesMockBackend: true,
    );

    final voiceTurnController = VoiceTurnController(
      repository: _FakeAiVoiceRepository(),
      recorder: _FakeAudioRecorder(),
      player: _FakeAudioPlayer(),
      localStorage: LocalStorageService(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          subscriptionControllerProvider
              .overrideWith((Ref ref) => subscriptionController),
          aiCoachControllerProvider
              .overrideWith((Ref ref) => aiCoachController),
          voiceTurnControllerProvider
              .overrideWith((Ref ref) => voiceTurnController),
        ],
        child: const MaterialApp(home: AiCoachPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'La conversacion por voz no esta incluida en tu estado actual. Activa o restaura la suscripcion para usarla.',
      ),
      findsOneWidget,
    );
  });
}

class _FakeSubscriptionRepository implements SubscriptionRepository {
  _FakeSubscriptionRepository({required EntitlementStatus status})
      : _status = status;

  final EntitlementStatus _status;

  @override
  Future<void> dispose() async {}

  @override
  Future<EntitlementStatus> getEntitlementStatus() async => _status;

  @override
  Future<SubscriptionPlan?> getMonthlyPlan() async => null;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> purchaseMonthlyPlan() async => true;

  @override
  Future<void> refreshAiChatQuota() async {}

  @override
  Future<void> restorePurchases() async {}

  @override
  Stream<EntitlementStatus> watchEntitlementStatus() =>
      const Stream<EntitlementStatus>.empty();
}

class _FakeAiCoachRepository implements AiCoachRepository {
  @override
  Future<AiCoachChatResponse> sendMessage(AiCoachChatRequest request) async {
    return const AiCoachChatResponse(
      assistantMessage: 'ok',
      safety: AiCoachSafetyMetadata(
        disclaimerShown: false,
        escalationRecommended: false,
        containsSensitiveContent: false,
      ),
      meta: AiCoachChatMeta(
        model: 'mock',
        provider: 'mock',
        requestId: 'req-1',
      ),
    );
  }
}

class _FakeAiVoiceRepository implements AiVoiceRepository {
  @override
  Future<VoiceTurnResponse> sendVoiceTurn(VoiceTurnRequest request) async {
    return const VoiceTurnResponse(
      userTranscript: 'hola',
      assistantText: 'respuesta',
      outputAudioBytes: <int>[1, 2, 3],
      outputAudioMimeType: 'audio/mpeg',
      voiceProfileUsed: 'warm',
      metadata: VoiceTurnMetadata(
        requestId: 'voice-1',
        provider: 'mock',
        model: 'mock',
        transcriptionModel: 'mock',
        ttsModel: 'mock',
      ),
    );
  }
}

class _FakeAudioRecorder implements AudioRecorder {
  @override
  Future<void> cancelRecording() async {}

  @override
  Future<void> deleteRecording(String path) async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<List<int>> readRecordingBytes(String path) async => <int>[1, 2, 3];

  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> startRecording() async {}

  @override
  Future<String> stopRecording() async => 'voice.m4a';
}

class _FakeAudioPlayer implements AudioPlayer {
  @override
  Future<void> dispose() async {}

  @override
  Future<void> playBytes(List<int> audioBytes,
      {required String mimeType}) async {}

  @override
  Future<void> stop() async {}
}
