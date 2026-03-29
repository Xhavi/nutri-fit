abstract class AudioPlayer {
  Future<void> playBytes(List<int> audioBytes, {required String mimeType});

  Future<void> stop();

  Future<void> dispose();
}
