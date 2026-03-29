import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/voice_turn_state.dart';
import '../controllers/ai_voice_providers.dart';

class VoiceTurnControls extends ConsumerWidget {
  const VoiceTurnControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final VoiceTurnState state = ref.watch(voiceTurnStateProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Voz (PTT por turnos)', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(
              'Base de arquitectura lista. TODO(V1): captura/reproducción real. '
              'Sin Realtime API, sin WebRTC, sin full duplex.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: state.isBusy || state.status == VoiceTurnStatus.recording
                      ? null
                      : () => ref.read(voiceTurnControllerProvider).startRecording(),
                  icon: const Icon(Icons.mic_rounded),
                  label: const Text('Iniciar grabación'),
                ),
                FilledButton.icon(
                  onPressed: state.status == VoiceTurnStatus.recording
                      ? () {
                          ref.read(voiceTurnControllerProvider).stopRecordingAndSend();
                        }
                      : null,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Detener y enviar'),
                ),
                TextButton(
                  onPressed: () => ref.read(voiceTurnControllerProvider).stopPlayback(),
                  child: const Text('Detener audio'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Estado: ${state.status.name}'),
            if (state.lastResponse != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                'Último texto asistente: ${state.lastResponse!.assistantText}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (state.errorMessage != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                state.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
