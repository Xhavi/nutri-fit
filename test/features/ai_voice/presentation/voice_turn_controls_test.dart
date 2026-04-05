import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_fit/core/services/local_storage_service.dart';
import 'package:nutri_fit/features/ai_voice/application/voice_turn_controller.dart';
import 'package:nutri_fit/features/ai_voice/domain/contracts/audio_player.dart';
import 'package:nutri_fit/features/ai_voice/domain/contracts/audio_recorder.dart';
import 'package:nutri_fit/features/ai_voice/domain/models/voice_turn_models.dart';
import 'package:nutri_fit/features/ai_voice/domain/repositories/ai_voice_repository.dart';
import 'package:nutri_fit/features/ai_voice/presentation/controllers/ai_voice_providers.dart';
import 'package:nutri_fit/features/ai_voice/presentation/widgets/voice_turn_controls.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('VoiceTurnControls stays stable on narrow screens', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final VoiceTurnController controller = VoiceTurnController(
      repository: _FakeAiVoiceRepository(),
      recorder: _FakeAudioRecorder(),
      player: _FakeAudioPlayer(),
      localStorage: LocalStorageService(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          voiceTurnControllerProvider.overrideWith((Ref ref) => controller),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: VoiceTurnControls(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Voz V2 (turnos)'), findsOneWidget);

    final TextButton stopAudioButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Detener audio'),
    );
    expect(stopAudioButton.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
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
