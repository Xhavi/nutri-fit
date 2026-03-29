import 'dart:io';

import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:path_provider/path_provider.dart';

import '../../domain/contracts/audio_player.dart';

class FlutterAudioPlayer implements AudioPlayer {
  FlutterAudioPlayer({audio.AudioPlayer? player}) : _player = player ?? audio.AudioPlayer();

  final audio.AudioPlayer _player;

  String? _lastResponseFilePath;

  @override
  Future<void> playBytes(List<int> audioBytes, {required String mimeType}) async {
    if (audioBytes.isEmpty) {
      return;
    }

    final Directory tempDirectory = await getTemporaryDirectory();
    final Directory voiceDirectory = Directory('${tempDirectory.path}/voice_responses');
    if (!voiceDirectory.existsSync()) {
      await voiceDirectory.create(recursive: true);
    }

    final String extension = mimeType.contains('wav') ? 'wav' : 'mp3';
    final String path =
        '${voiceDirectory.path}/voice_response_${DateTime.now().millisecondsSinceEpoch}.$extension';

    final File responseFile = File(path);
    await responseFile.writeAsBytes(audioBytes, flush: true);
    _lastResponseFilePath = path;

    await _player.stop();
    await _player.play(audio.DeviceFileSource(path));
  }

  @override
  Future<void> stop() async {
    await _player.stop();
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
    final String? path = _lastResponseFilePath;
    if (path != null) {
      final File file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }
    }
  }
}
