import 'package:flutter/material.dart';

import '../../domain/models/ai_coach_chat_message.dart';

class AiCoachMessageBubble extends StatelessWidget {
  const AiCoachMessageBubble({required this.message, super.key});

  final AiCoachChatMessage message;

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.author == AiCoachMessageAuthor.user;
    final bool isSystem = message.author == AiCoachMessageAuthor.system;

    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color background =
        isSystem ? colors.surfaceContainerHighest : (isUser ? colors.primary : colors.surface);
    final Color textColor = isUser ? colors.onPrimary : colors.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Card(
          color: background,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(message.text, style: TextStyle(color: textColor)),
                if (message.isSensitive || message.escalationRecommended)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: <Widget>[
                        if (message.isSensitive)
                          const _Tag(
                            label: 'Contenido sensible',
                            icon: Icons.health_and_safety_rounded,
                          ),
                        if (message.escalationRecommended)
                          const _Tag(
                            label: 'Buscar apoyo profesional',
                            icon: Icons.local_hospital_rounded,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.onErrorContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}
