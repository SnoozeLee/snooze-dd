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

    try {
      await _player.setVolume(volume);
      // 后续可扩展加载本地 assets/audio/*.mp3
      // 目前提供安全优雅的降级支持
    } catch (e) {
      debugPrint('Failed to play chime: $e');
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
