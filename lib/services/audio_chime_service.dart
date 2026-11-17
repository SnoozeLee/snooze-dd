import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/checkpoint.dart';

/// 柔和伴随提示音播放服务
class AudioChimeService {
  static final AudioChimeService _instance = AudioChimeService._internal();
  factory AudioChimeService() => _instance;
  AudioChimeService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> init() async {
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      debugPrint('AudioChimeService init error: $e');
    }
  }

  /// 播放指定类型的轻提示音
  Future<void> playChime(ChimeSoundType soundType, {double volume = 0.6}) async {
    if (soundType == ChimeSoundType.none) return;

    String fileName;
    switch (soundType) {
      case ChimeSoundType.gentleBell:
        fileName = 'audio/gentle_bell.wav';
        break;
      case ChimeSoundType.waterDrop:
        fileName = 'audio/water_drop.wav';
        break;
      case ChimeSoundType.singingBowl:
        fileName = 'audio/singing_bowl.wav';
        break;
      case ChimeSoundType.none:
        return;
    }

    try {
      await _player.stop();
      await _player.setVolume(volume);
      await _player.play(AssetSource(fileName));
    } catch (e) {
      debugPrint('Failed to play chime: $e');
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
