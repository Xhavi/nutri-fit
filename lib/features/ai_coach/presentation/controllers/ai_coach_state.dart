import '../../domain/models/ai_coach_chat_message.dart';

class AiCoachState {
  const AiCoachState({
    required this.messages,
    required this.isSending,
    this.errorMessage,
    this.lastFailedInput,
    this.disclaimerVisible = true,
    this.usesMockBackend = true,
  });

  final List<AiCoachChatMessage> messages;
  final bool isSending;
  final String? errorMessage;
  final String? lastFailedInput;
  final bool disclaimerVisible;
  final bool usesMockBackend;

  AiCoachState copyWith({
    List<AiCoachChatMessage>? messages,
    bool? isSending,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? lastFailedInput,
    bool clearLastFailedInput = false,
    bool? disclaimerVisible,
    bool? usesMockBackend,
  }) {
    return AiCoachState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      lastFailedInput: clearLastFailedInput
          ? null
          : (lastFailedInput ?? this.lastFailedInput),
      disclaimerVisible: disclaimerVisible ?? this.disclaimerVisible,
      usesMockBackend: usesMockBackend ?? this.usesMockBackend,
    );
  }

  factory AiCoachState.initial({required bool usesMockBackend}) {
    return AiCoachState(
      messages: const <AiCoachChatMessage>[],
      isSending: false,
      usesMockBackend: usesMockBackend,
    );
  }
}
