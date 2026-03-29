import 'dart:convert';

import 'transcription_result.dart';
import 'voice_profile.dart';

class VoiceTurnRequest {
  const VoiceTurnRequest({
    required this.inputAudio,
    this.audioMimeType = 'audio/m4a',
    this.transcript,
    this.userContext,
    this.voiceProfile,
    this.voiceStyleInstructions,
    this.turnId,
    this.conversationId,
    this.locale,
  });

  final List<int> inputAudio;
  final String audioMimeType;
  final String? transcript;
  final VoiceUserContext? userContext;
  final VoiceProfile? voiceProfile;
  final String? voiceStyleInstructions;
  final String? turnId;
  final String? conversationId;
  final String? locale;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'audio': <String, dynamic>{
        'base64': base64Encode(inputAudio),
        'mimeType': audioMimeType,
        'filename': 'voice_turn.m4a',
      },
      if (locale != null) 'metadata': <String, dynamic>{'locale': locale},
      if (userContext != null) 'context': userContext!.toContextJson(),
      if (conversationId != null || turnId != null || transcript != null)
        'conversation': <String, dynamic>{
          if (conversationId != null) 'conversationId': conversationId,
          if (transcript != null)
            'recentTurns': <Map<String, String>>[
              <String, String>{
                'userText': transcript!,
                'assistantText': 'pending',
              },
            ],
        },
      if (voiceProfile != null || voiceStyleInstructions != null)
        'voice': <String, dynamic>{
          if (voiceProfile?.id != null) 'profileId': voiceProfile!.id,
          'format': 'mp3',
        },
    };
  }
}

class VoiceTurnResponse {
  const VoiceTurnResponse({
    required this.assistantText,
    required this.outputAudioBytes,
    required this.outputAudioMimeType,
    required this.userTranscript,
    required this.voiceProfileUsed,
    required this.metadata,
    this.safety,
  });

  final String assistantText;
  final List<int> outputAudioBytes;
  final String outputAudioMimeType;
  final String userTranscript;
  final String voiceProfileUsed;
  final VoiceTurnMetadata metadata;
  final VoiceTurnSafety? safety;

  TranscriptionResult? get transcription {
    if (userTranscript.trim().isEmpty) {
      return null;
    }

    return TranscriptionResult(text: userTranscript);
  }

  factory VoiceTurnResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> assistantAudio =
        json['assistantAudio'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    return VoiceTurnResponse(
      assistantText: json['assistantText'] as String? ?? '',
      outputAudioBytes: _decodeAudioBytes(assistantAudio['base64'] as String?),
      outputAudioMimeType: assistantAudio['mimeType'] as String? ?? 'audio/mpeg',
      userTranscript: json['userTranscript'] as String? ?? '',
      voiceProfileUsed: json['voiceProfileUsed'] as String? ?? 'coach_default',
      metadata: VoiceTurnMetadata.fromJson(
        json['meta'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      safety: json['safety'] == null
          ? null
          : VoiceTurnSafety.fromJson(json['safety'] as Map<String, dynamic>),
    );
  }

  static List<int> _decodeAudioBytes(String? outputAudioBase64) {
    if (outputAudioBase64 == null || outputAudioBase64.isEmpty) {
      return const <int>[];
    }

    return base64Decode(outputAudioBase64);
  }
}

class VoiceTurnMetadata {
  const VoiceTurnMetadata({
    required this.requestId,
    required this.provider,
    required this.model,
    required this.transcriptionModel,
    required this.ttsModel,
    this.locale,
  });

  final String requestId;
  final String provider;
  final String model;
  final String transcriptionModel;
  final String ttsModel;
  final String? locale;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'requestId': requestId,
      'provider': provider,
      'model': model,
      'transcriptionModel': transcriptionModel,
      'ttsModel': ttsModel,
      if (locale != null) 'locale': locale,
    };
  }

  factory VoiceTurnMetadata.fromJson(Map<String, dynamic> json) {
    return VoiceTurnMetadata(
      requestId: json['requestId'] as String? ?? '',
      provider: json['provider'] as String? ?? 'unknown',
      model: json['model'] as String? ?? 'unknown',
      transcriptionModel: json['transcriptionModel'] as String? ?? 'unknown',
      ttsModel: json['ttsModel'] as String? ?? 'unknown',
      locale: json['locale'] as String?,
    );
  }
}

class VoiceTurnSafety {
  const VoiceTurnSafety({required this.disclaimer, this.flags = const <String>[]});

  final String disclaimer;
  final List<String> flags;

  factory VoiceTurnSafety.fromJson(Map<String, dynamic> json) {
    return VoiceTurnSafety(
      disclaimer: json['disclaimer'] as String? ?? '',
      flags: ((json['flags'] as List<dynamic>?) ?? const <dynamic>[])
          .map((dynamic item) => item.toString())
          .toList(growable: false),
    );
  }
}

class VoiceUserContext {
  const VoiceUserContext({
    this.userId,
    this.goal,
    this.locale,
    this.additional,
  });

  final String? userId;
  final String? goal;
  final String? locale;
  final Map<String, dynamic>? additional;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (userId != null) 'userId': userId,
      if (goal != null) 'goal': goal,
      if (locale != null) 'locale': locale,
      if (additional != null) 'additional': additional,
    };
  }

  Map<String, dynamic> toContextJson() {
    return <String, dynamic>{
      if (goal != null) 'goal': <String, dynamic>{'description': goal},
      if (additional != null) ...additional!,
    };
  }
}
