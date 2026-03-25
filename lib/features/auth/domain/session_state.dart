enum SessionStatus { initializing, unauthenticated, needsOnboarding, authenticated }

class SessionState {
  const SessionState({required this.status, this.userId, this.errorMessage});

  final SessionStatus status;
  final String? userId;
  final String? errorMessage;

  SessionState copyWith({SessionStatus? status, String? userId, String? errorMessage}) {
    return SessionState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      errorMessage: errorMessage,
    );
  }

  factory SessionState.initial() {
    return const SessionState(status: SessionStatus.initializing);
  }
}
