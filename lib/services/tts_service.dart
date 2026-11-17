import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 离线文本朗读 (Text-to-Speech) 服务
///
/// 封装原生 TTS 引擎，内置防并发语音朗读队列与音频闪避设置。
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  final List<String> _speakQueue = [];

  bool get isSpeaking => _isSpeaking;

  /// 初始化 TTS 引擎参数
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage("zh-CN");
      await _flutterTts.setSpeechRate(0.5); // 温和适中的语速
      await _flutterTts.setVolume(0.8); // 柔和弱提醒音量
      await _flutterTts.setPitch(1.0);

      // 设置 iOS 后台音频混音分类（允许混音闪避）
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.ambient,
        [
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.duckOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _processNextInQueue();
      });

      _flutterTts.setErrorHandler((dynamic message) {
        debugPrint('TTS Error: $message');
        _isSpeaking = false;
        _processNextInQueue();
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  /// 顺序朗读自定义播报文本
  Future<void> speak(String text, {double volume = 0.8}) async {
    if (text.trim().isEmpty) return;

    if (!_isInitialized) {
      await init();
    }

    _speakQueue.add(text);
    if (!_isSpeaking) {
      _processNextInQueue(volume: volume);
    }
  }

  void _processNextInQueue({double volume = 0.8}) async {
    if (_speakQueue.isEmpty) {
      _isSpeaking = false;
      return;
    }

    final text = _speakQueue.removeAt(0);
    _isSpeaking = true;

    try {
      await _flutterTts.setVolume(volume);
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Failed to speak text: $e');
      _isSpeaking = false;
      _processNextInQueue(volume: volume);
    }
  }

  /// 停止当前正在播放的所有播报并清空队列
  Future<void> stop() async {
    _speakQueue.clear();
    _isSpeaking = false;
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }
}
