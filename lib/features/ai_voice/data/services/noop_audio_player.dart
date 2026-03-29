import '../../domain/contracts/audio_player.dart';

class NoopAudioPlayer implements AudioPlayer {
  @override
  Future<void> playBytes(List<int> audioBytes, {required String mimeType}) async {
    // TODO(V1): Integrar reproducción de audio por bytes para respuesta del backend.
    // TODO(V2): Mejorar fluidez con buffering y transiciones suaves.
  }

  @override
  Future<void> stop() async {
    // TODO(V1): Detener reproducción en curso.
  }

  @override
  Future<void> dispose() async {}
}
