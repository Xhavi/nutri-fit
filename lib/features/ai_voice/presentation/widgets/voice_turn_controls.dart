import 'package:flutter/material.dart';

import '../../application/voice_turn_controller.dart';
import '../../application/voice_turn_state.dart';
import '../../domain/models/voice_turn_models.dart';
import '../controllers/ai_voice_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceTurnControls extends ConsumerWidget {
  const VoiceTurnControls({this.enabled = true, super.key});

  final bool enabled;

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
            Text('Voz V2 (turnos)', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(
              enabled
                  ? 'Habla por turnos, recibe respuesta con perfil de voz y reproduce de nuevo cuando quieras.'
                  : 'Bloqueado: activa AI Premium para usar conversación por voz.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: state.selectedVoiceProfile.id,
              decoration: const InputDecoration(
                labelText: 'Perfil de voz',
                prefixIcon: Icon(Icons.record_voice_over_rounded),
              ),
              items: state.availableProfiles
                  .map(
                    (profile) => DropdownMenuItem<String>(
                      value: profile.id,
                      child: Text('${profile.label} • ${profile.description ?? ''}'),
                    ),
                  )
                  .toList(growable: false),
              onChanged: !enabled
                  ? null
                  : (String? id) {
                      if (id == null) {
                        return;
                      }

                      final selected = state.availableProfiles.firstWhere(
                        (profile) => profile.id == id,
                        orElse: () => state.selectedVoiceProfile,
                      );
                      controller.setVoiceProfile(selected);
                    },
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reproducir automáticamente la respuesta'),
              subtitle: const Text('Si está apagado, podrás escuchar manualmente con "Reproducir".'),
              value: state.autoplayEnabled,
              onChanged: enabled ? controller.setAutoplayEnabled : null,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onLongPressStart: enabled ? (_) => controller.startRecording() : null,
              onLongPressEnd: enabled ? (_) => controller.stopRecording() : null,
              onLongPressCancel: enabled ? () => controller.cancelRecording() : null,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: (!enabled || state.isBusy) ? null : () => controller.startRecording(),
                  icon: Icon(
                    state.status == VoiceTurnStatus.recording
                        ? Icons.graphic_eq_rounded
                        : Icons.keyboard_voice_rounded,
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
                  onPressed: enabled && state.status == VoiceTurnStatus.recording
                      ? () => controller.stopRecording()
                      : null,
                  icon: const Icon(Icons.stop_rounded),
                  label: const Text('Detener y enviar'),
                ),
                OutlinedButton.icon(
                  onPressed: enabled && state.status == VoiceTurnStatus.recording
                      ? () => controller.cancelRecording()
                      : null,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Cancelar'),
                ),
                TextButton.icon(
                  onPressed: enabled && state.recording.localFilePath != null
                      ? () => controller.retryLastTurn()
                      : null,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar turno'),
                ),
                TextButton.icon(
                  onPressed:
                      enabled && state.lastResponse != null ? () => controller.replayLastResponse() : null,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Reproducir respuesta'),
                ),
                TextButton.icon(
                  onPressed: enabled ? () => controller.stopPlayback() : null,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('Detener audio'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _StatusChip(status: state.status),
            if (state.status == VoiceTurnStatus.processingBackend ||
                state.status == VoiceTurnStatus.uploading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(minHeight: 4),
              ),
            if (state.lastResponse != null) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                'Última respuesta (${state.lastResponse!.voiceProfileUsed})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Transcript: ${state.lastResponse!.userTranscript.isEmpty ? '(sin transcript)' : state.lastResponse!.userTranscript}',
              ),
              const SizedBox(height: 4),
              Text('Coach: ${state.lastResponse!.assistantText}'),
            ],
            if (state.history.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text('Historial de voz', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              ...state.history.take(3).map(_HistoryItem.new),
            ],
            if (state.errorMessage != null) ...<Widget>[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final VoiceTurnStatus status;

  @override
  Widget build(BuildContext context) {
    final (String label, IconData icon) = switch (status) {
      VoiceTurnStatus.idle => ('Listo', Icons.check_circle_outline_rounded),
      VoiceTurnStatus.requestingPermission => ('Pidiendo permiso', Icons.lock_open_rounded),
      VoiceTurnStatus.recording => ('Grabando', Icons.mic_rounded),
      VoiceTurnStatus.uploading => ('Subiendo audio', Icons.cloud_upload_rounded),
      VoiceTurnStatus.processingBackend => ('Procesando respuesta', Icons.psychology_rounded),
      VoiceTurnStatus.responseReady => ('Respuesta lista', Icons.mark_chat_read_rounded),
      VoiceTurnStatus.playingAudio => ('Reproduciendo', Icons.volume_up_rounded),
      VoiceTurnStatus.error => ('Error', Icons.error_outline_rounded),
    };

    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem(this.item);

  final VoiceTurnHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${item.createdAt.toLocal()} • perfil ${item.voiceProfileUsed}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text('Audio enviado: ${item.inputAudioPath ?? 'n/a'}', maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('Transcript: ${item.userTranscript.isEmpty ? '(sin transcript)' : item.userTranscript}'),
            Text('Respuesta: ${item.assistantText}', maxLines: 2, overflow: TextOverflow.ellipsis),
            Text('Audio respuesta: ${item.outputAudioMimeType} (${item.outputAudioBytes.length} bytes)'),
          ],
        ),
      ),
    );
  }
}
