abstract class AudioRecorder {
  Future<void> requestPermission();

  Future<void> startRecording();

  Future<String> stopRecording();

  Future<void> cancelRecording();

  Future<List<int>> readRecordingBytes(String path);

  Future<void> deleteRecording(String path);

  Future<void> dispose();
}
