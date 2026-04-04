import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/layouts/internal_base_layout.dart';
import '../../../ai_voice/presentation/widgets/voice_turn_controls.dart';
import '../../../subscriptions/domain/models/entitlement_status.dart';
import '../../../subscriptions/presentation/controllers/subscription_providers.dart';
import '../../../subscriptions/presentation/controllers/subscription_state.dart';
import '../../domain/models/ai_coach_chat_message.dart';
import '../controllers/ai_coach_providers.dart';
import '../controllers/ai_coach_state.dart';
import '../widgets/ai_coach_message_bubble.dart';

class AiCoachPage extends ConsumerStatefulWidget {
  const AiCoachPage({super.key});

  @override
  ConsumerState<AiCoachPage> createState() => _AiCoachPageState();
}

class _AiCoachPageState extends ConsumerState<AiCoachPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final String message = _textController.text;
    _textController.clear();

    await ref.read(aiCoachControllerProvider).sendMessage(message);
    await ref.read(subscriptionControllerProvider).refreshAiChatQuota();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final AiCoachState state = ref.watch(aiCoachStateProvider);
    final SubscriptionState subscriptionState =
        ref.watch(subscriptionStateProvider);
    final EntitlementStatus entitlement = subscriptionState.status;
    final FeatureEntitlementStatus chatAccess = entitlement.chatAccess;
    final FeatureEntitlementStatus voiceAccess = entitlement.voiceAccess;
    final bool canUseAiChat = subscriptionState.hasChatAccess;
    final bool canUseAiVoice = subscriptionState.hasVoiceAccess;
    final bool showAccessNotice = !canUseAiChat || !canUseAiVoice;

    ref.listen<AiCoachState>(aiCoachStateProvider, (_, AiCoachState next) {
      _scrollToBottom();
    });

    return InternalBaseLayout(
      title: 'AI Coach',
      currentIndex: 4,
      child: Column(
        children: <Widget>[
          _SafetyNoticeCard(
            disclaimerVisible: state.disclaimerVisible,
            usesMockBackend: state.usesMockBackend,
            onDismiss: () => ref.read(aiCoachControllerProvider).dismissDisclaimer(),
          ),
          if (showAccessNotice)
            _AccessNoticeCard(
              message: _accessMessage(
                chatAccess: chatAccess,
                voiceAccess: voiceAccess,
              ),
              onOpenPaywall: () => context.push(AppRoutePaths.paywall),
            ),
          _QuotaIndicatorCard(chatAccess: chatAccess),
          if (chatAccess.reason == 'monthly_quota_exceeded')
            _QuotaExhaustedCard(
              onOpenPaywall: () => context.push(AppRoutePaths.paywall),
            ),
          if (state.errorMessage != null)
            _ErrorBanner(
              message: state.errorMessage!,
              onRetry: state.lastFailedInput == null
                  ? null
                  : () => ref.read(aiCoachControllerProvider).retryLastMessage(),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: state.messages.isEmpty
                ? const _EmptyChatState()
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: state.messages.length + (state.isSending ? 1 : 0),
                    itemBuilder: (BuildContext context, int index) {
                      if (index >= state.messages.length) {
                        return const _AssistantLoadingBubble();
                      }

                      final AiCoachChatMessage message = state.messages[index];
                      return AiCoachMessageBubble(message: message);
                    },
                  ),
          ),
          const SizedBox(height: 8),
          _Composer(
            controller: _textController,
            isSending: state.isSending,
            enabled: canUseAiChat,
            onSend: _sendMessage,
          ),
          const SizedBox(height: 8),
          VoiceTurnControls(enabled: canUseAiVoice),
        ],
      ),
    );
  }

  String _accessMessage({
    required FeatureEntitlementStatus chatAccess,
    required FeatureEntitlementStatus voiceAccess,
  }) {
    if (chatAccess.reason == 'pending_verification' ||
        voiceAccess.reason == 'pending_verification') {
      return 'Estamos validando tu compra premium. Intenta de nuevo en un momento.';
    }

    if (chatAccess.reason == 'monthly_quota_exceeded') {
      return 'Agotaste tu cuota mensual de chat IA. Puedes esperar la renovacion o revisar planes.';
    }

    if (!chatAccess.entitled && !voiceAccess.entitled) {
      return 'Las funciones premium de IA estan bloqueadas. Activa la suscripcion para continuar.';
    }

    if (!chatAccess.allowed &&
        chatAccess.reason == 'subscription_not_active' &&
        !voiceAccess.allowed &&
        voiceAccess.reason == 'subscription_not_active') {
      return 'Tu suscripcion premium no esta activa todavia. Restaura la compra o revisa tu estado.';
    }

    if (!chatAccess.entitled) {
      return 'El chat premium esta bloqueado en tu plan actual. Activa o restaura la suscripcion para continuar.';
    }

    if (!voiceAccess.entitled) {
      return 'La conversacion por voz no esta incluida en tu estado actual. Activa o restaura la suscripcion para usarla.';
    }

    if (!chatAccess.allowed) {
      return 'El chat premium no esta disponible por ahora. Revisa tu suscripcion o intenta mas tarde.';
    }

    return 'La conversacion por voz no esta disponible por ahora. Revisa tu suscripcion o intenta mas tarde.';
  }
}

class _AccessNoticeCard extends StatelessWidget {
  const _AccessNoticeCard({
    required this.message,
    required this.onOpenPaywall,
  });

  final String message;
  final VoidCallback onOpenPaywall;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            const Icon(Icons.lock_rounded),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
            FilledButton(
              onPressed: onOpenPaywall,
              child: const Text('Ver planes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuotaIndicatorCard extends StatelessWidget {
  const _QuotaIndicatorCard({required this.chatAccess});

  final FeatureEntitlementStatus chatAccess;

  @override
  Widget build(BuildContext context) {
    if (!chatAccess.hasQuota) {
      return const SizedBox.shrink();
    }

    final double progress = chatAccess.quota == 0
        ? 0
        : (chatAccess.used / chatAccess.quota).clamp(0, 1).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Tu cuota mensual de AI Coach',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text('Consumido: ${chatAccess.used} / ${chatAccess.quota}'),
            Text('Restante: ${chatAccess.remaining} mensajes'),
          ],
        ),
      ),
    );
  }
}

class _QuotaExhaustedCard extends StatelessWidget {
  const _QuotaExhaustedCard({required this.onOpenPaywall});

  final VoidCallback onOpenPaywall;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            const Icon(Icons.hourglass_disabled_rounded),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Agotaste tu cuota mensual de AI Coach. Puedes esperar la renovacion o revisar planes.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            FilledButton.tonal(
              onPressed: onOpenPaywall,
              child: const Text('Ver planes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyNoticeCard extends StatelessWidget {
  const _SafetyNoticeCard({
    required this.disclaimerVisible,
    required this.usesMockBackend,
    required this.onDismiss,
  });

  final bool disclaimerVisible;
  final bool usesMockBackend;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    if (!disclaimerVisible) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.verified_user_rounded),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Guia de bienestar, no diagnostico medico',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'El AI Coach te ayuda con habitos saludables y planificacion general. '
                    'Si presentas sintomas preocupantes, consulta a un profesional de salud.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (usesMockBackend)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Modo actual: adaptador mock (sin backend real desplegado).',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Ocultar',
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.smart_toy_rounded,
            size: 46,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza una conversacion con tu AI Coach',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            'Ejemplo: "Que cena me recomiendas segun mi objetivo y lo que comi hoy?"',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AssistantLoadingBubble extends StatelessWidget {
  const _AssistantLoadingBubble();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.isSending,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final bool enabled;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            maxLines: 4,
            minLines: 1,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
            decoration: InputDecoration(
              labelText: 'Escribe tu mensaje',
              hintText: enabled
                  ? 'Cuentame que necesitas para avanzar hoy...'
                  : 'Necesitas cuota disponible en AI Premium para enviar mensajes.',
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: (!enabled || isSending) ? null : onSend,
          icon: const Icon(Icons.send_rounded),
          label: const Text('Enviar'),
        ),
      ],
    );
  }
}
