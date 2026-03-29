import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart' as record;

import '../../domain/contracts/audio_recorder.dart';

class FlutterAudioRecorder implements AudioRecorder {
  FlutterAudioRecorder({record.AudioRecorder? recorder})
      : _recorder = recorder ?? record.AudioRecorder();

  final record.AudioRecorder _recorder;

  String? _activeRecordingPath;

  @override
  Future<void> requestPermission() async {
    final PermissionStatus status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw StateError('Microphone permission denied');
    }
  }

  @override
  Future<void> startRecording() async {
    final Directory tempDirectory = await getTemporaryDirectory();
    final Directory voiceDirectory = Directory('${tempDirectory.path}/voice_turns');
    if (!voiceDirectory.existsSync()) {
      await voiceDirectory.create(recursive: true);
    }

    final String path =
        '${voiceDirectory.path}/voice_turn_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _activeRecordingPath = path;

    await _recorder.start(
      const record.RecordConfig(
        encoder: record.AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
      ),
      path: path,
    );
  }

  @override
  Future<String> stopRecording() async {
    final String? path = await _recorder.stop();
    if (path == null || path.isEmpty) {
      throw StateError('Recording path unavailable');
    }
    _activeRecordingPath = null;
    return path;
  }

  @override
  Future<void> cancelRecording() async {
    await _recorder.stop();
    final String? path = _activeRecordingPath;
    _activeRecordingPath = null;

    if (path != null) {
      final File file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }
    }
  }

  @override
  Future<List<int>> readRecordingBytes(String path) async {
    final File file = File(path);
    if (!file.existsSync()) {
      throw StateError('Recorded file not found');
    }
    return file.readAsBytes();
  }

  @override
  Future<void> deleteRecording(String path) async {
    final File file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  @override
  Future<void> dispose() async {
    await _recorder.dispose();
  }
}
