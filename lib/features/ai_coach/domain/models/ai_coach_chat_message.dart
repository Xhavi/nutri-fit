enum AiCoachMessageAuthor { user, assistant, system }

class AiCoachChatMessage {
  const AiCoachChatMessage({
    required this.id,
    required this.text,
    required this.author,
    required this.createdAt,
    this.isSensitive = false,
    this.escalationRecommended = false,
  });

  final String id;
  final String text;
  final AiCoachMessageAuthor author;
  final DateTime createdAt;
  final bool isSensitive;
  final bool escalationRecommended;
}
