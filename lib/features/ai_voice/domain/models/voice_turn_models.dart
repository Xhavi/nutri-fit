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
      'inputAudioBase64': base64Encode(inputAudio),
      'audioMimeType': audioMimeType,
      if (transcript != null) 'transcript': transcript,
      if (userContext != null) 'userContext': userContext!.toJson(),
      if (voiceProfile != null) 'voiceProfile': voiceProfile!.toJson(),
      if (voiceStyleInstructions != null) 'voiceStyleInstructions': voiceStyleInstructions,
      if (turnId != null) 'turnId': turnId,
      if (conversationId != null) 'conversationId': conversationId,
      if (locale != null) 'locale': locale,
    };
  }
}

class VoiceTurnResponse {
  const VoiceTurnResponse({
    required this.assistantText,
    required this.outputAudio,
    required this.outputAudioMimeType,
    required this.metadata,
    this.transcription,
  });

  final String assistantText;
  final List<int> outputAudio;
  final String outputAudioMimeType;
  final VoiceTurnMetadata metadata;
  final TranscriptionResult? transcription;

  factory VoiceTurnResponse.fromJson(Map<String, dynamic> json) {
    return VoiceTurnResponse(
      assistantText: json['assistantText'] as String? ?? '',
      outputAudio: _decodeAudioBytes(json['outputAudioBase64'] as String?),
      outputAudioMimeType: json['outputAudioMimeType'] as String? ?? 'audio/mpeg',
      metadata: VoiceTurnMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      transcription: json['transcription'] == null
          ? null
          : TranscriptionResult.fromJson(json['transcription'] as Map<String, dynamic>),
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
    required this.turnMode,
    required this.latencyMs,
  });

  final String requestId;
  final String provider;
  final String model;
  final String turnMode;
  final int latencyMs;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'requestId': requestId,
      'provider': provider,
      'model': model,
      'turnMode': turnMode,
      'latencyMs': latencyMs,
    };
  }

  factory VoiceTurnMetadata.fromJson(Map<String, dynamic> json) {
    return VoiceTurnMetadata(
      requestId: json['requestId'] as String? ?? '',
      provider: json['provider'] as String? ?? 'unknown',
      model: json['model'] as String? ?? 'unknown',
      turnMode: json['turnMode'] as String? ?? 'ptt',
      latencyMs: json['latencyMs'] as int? ?? 0,
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
}
