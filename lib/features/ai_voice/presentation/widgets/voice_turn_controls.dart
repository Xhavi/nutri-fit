import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/voice_turn_controller.dart';
import '../../application/voice_turn_state.dart';
import '../controllers/ai_voice_providers.dart';

class VoiceTurnControls extends ConsumerWidget {
  const VoiceTurnControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final VoiceTurnState state = ref.watch(voiceTurnStateProvider);
    final VoiceTurnController controller = ref.read(voiceTurnControllerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Voz (PTT por turnos)', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(
              'Push-to-talk en turnos: mantén pulsado para grabar y suelta para enviar.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onLongPressStart: (_) => controller.startRecording(),
              onLongPressEnd: (_) => controller.stopRecording(),
              onLongPressCancel: () => controller.cancelRecording(),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: state.isBusy ? null : () => controller.startRecording(),
                  icon: Icon(
                    state.status == VoiceTurnStatus.recording
                        ? Icons.mic
                        : Icons.mic_none_rounded,
                  ),
                  label: Text(
                    state.status == VoiceTurnStatus.recording
                        ? 'Grabando... suelta para enviar'
                        : 'Mantener pulsado para hablar',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: state.status == VoiceTurnStatus.recording
                      ? () => controller.stopRecording()
                      : null,
                  icon: const Icon(Icons.stop_rounded),
                  label: const Text('Detener y enviar'),
                ),
                OutlinedButton.icon(
                  onPressed: state.status == VoiceTurnStatus.recording
                      ? () => controller.cancelRecording()
                      : null,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Cancelar'),
                ),
                TextButton.icon(
                  onPressed: state.recording.localFilePath == null
                      ? null
                      : () => controller.retryLastTurn(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                ),
                TextButton.icon(
                  onPressed: () => controller.stopPlayback(),
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('Detener audio'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Estado: ${_statusLabel(state.status)}'),
            if (state.recording.localFilePath != null) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                'Audio temporal: ${state.recording.localFilePath}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (state.lastResponse != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                'Transcript: ${state.lastResponse!.transcription?.text ?? '(sin transcript)'}',
              ),
              const SizedBox(height: 6),
              Text(
                'Coach: ${state.lastResponse!.assistantText}',
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

  String _statusLabel(VoiceTurnStatus status) {
    switch (status) {
      case VoiceTurnStatus.idle:
        return 'idle';
      case VoiceTurnStatus.requestingPermission:
        return 'requesting_permission';
      case VoiceTurnStatus.recording:
        return 'recording';
      case VoiceTurnStatus.processing:
        return 'processing';
      case VoiceTurnStatus.transcriptReady:
        return 'transcript_ready';
      case VoiceTurnStatus.responseReady:
        return 'response_ready';
      case VoiceTurnStatus.playingAudio:
        return 'playing_audio';
      case VoiceTurnStatus.error:
        return 'error';
    }
  }
}
