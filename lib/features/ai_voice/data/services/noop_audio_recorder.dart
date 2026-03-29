import '../../domain/contracts/audio_recorder.dart';

class NoopAudioRecorder implements AudioRecorder {
  @override
  Future<void> requestPermission() async {
    // TODO(V1): Solicitar permisos reales de micrófono en iOS/Android.
  }

  @override
  Future<void> startRecording() async {
    // TODO(V1): Integrar plugin de captura de audio y formato recomendado.
  }

  @override
  Future<String> stopRecording() async {
    // TODO(V1): Devolver path real del archivo generado por grabación.
    return '';
  }

  @override
  Future<List<int>> readRecordingBytes(String path) async {
    // TODO(V1): Leer bytes del archivo de audio local.
    return const <int>[];
  }

  @override
  Future<void> dispose() async {}
}
