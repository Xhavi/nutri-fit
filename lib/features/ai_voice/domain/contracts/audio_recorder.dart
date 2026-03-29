abstract class AudioRecorder {
  Future<void> requestPermission();

  Future<void> startRecording();

  Future<String> stopRecording();

  Future<List<int>> readRecordingBytes(String path);

  Future<void> dispose();
}
