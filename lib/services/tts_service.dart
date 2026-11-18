import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 离线文本朗读 (Text-to-Speech) 服务
///
/// 封装原生 TTS 引擎，具备国产 Android 系统（MIUI/HyperOS 等）与多平台兼容性，
/// 内置防并发语音朗读队列、语言自适应回退以及等待播放完成机制。
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  String _activeLanguage = "zh-CN";

  final List<String> _speakQueue = [];

  bool get isSpeaking => _isSpeaking;
  bool get isInitialized => _isInitialized;
  String get activeLanguage => _activeLanguage;

  /// 初始化 TTS 引擎参数并适配目标平台
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. 语言自适应适配（针对国产 ROM 多种中文代码标识做回退）
      await _setupLanguage();

      // 2. 基础语音参数配置
      await _flutterTts.setSpeechRate(kIsWeb ? 1.0 : 0.5);
      await _flutterTts.setVolume(0.8);
      await _flutterTts.setPitch(1.0);

      // 3. Android 专属配置：启用朗读完成等待，避免竞态打断
      if (!kIsWeb && Platform.isAndroid) {
        try {
          await _flutterTts.awaitSpeakCompletion(true);
        } catch (_) {}
      }

      // 4. iOS 后台音频混音分类配置
      if (!kIsWeb && Platform.isIOS) {
        try {
          await _flutterTts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.ambient,
            [
              IosTextToSpeechAudioCategoryOptions.mixWithOthers,
              IosTextToSpeechAudioCategoryOptions.duckOthers,
            ],
            IosTextToSpeechAudioMode.voicePrompt,
          );
        } catch (_) {}
      }

      // 5. 注册事件回调监听
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _processNextInQueue();
      });

      _flutterTts.setErrorHandler((dynamic message) {
        debugPrint('TTS Error Handler: $message');
        _isSpeaking = false;
        _processNextInQueue();
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        _processNextInQueue();
      });

      _isInitialized = true;
      debugPrint('TTS Service initialized successfully with language: $_activeLanguage');
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  /// 适配中文语言支持（优先 zh-CN，依次回退 zh, zh_CN, cmn-Hans-CN）
  Future<void> _setupLanguage() async {
    final candidateLangs = ["zh-CN", "zh", "zh_CN", "cmn-Hans-CN"];
    for (final lang in candidateLangs) {
      try {
        final available = await _flutterTts.isLanguageAvailable(lang);
        if (available == true || available == 1) {
          await _flutterTts.setLanguage(lang);
          _activeLanguage = lang;
          return;
        }
      } catch (_) {}
    }

    // 若上述检查无法确认，默认尝试 setLanguage("zh-CN")
    try {
      await _flutterTts.setLanguage("zh-CN");
      _activeLanguage = "zh-CN";
    } catch (_) {}
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

    // 8秒超时安全兜底，防止平台层因音频抢占丢失 onComplete 导致队列永久锁死
    Timer(const Duration(seconds: 8), () {
      if (_isSpeaking) {
        debugPrint('TTS timeout safety watchdog triggered, releasing queue for next item.');
        _isSpeaking = false;
        _processNextInQueue(volume: volume);
      }
    });

    try {
      // 重新应用音量与当前语言（避免受其它音频会话覆盖）
      await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
      await _flutterTts.setSpeechRate(kIsWeb ? 1.0 : 0.5);

      final result = await _flutterTts.speak(text);
      debugPrint('TTS speak executed for "$text", platform result: $result');

      // 部分非 Android 平台或旧引擎若不触发 CompletionHandler，依靠 result 驱动或兜底
      if (!kIsWeb && Platform.isAndroid) {
        // 在启用了 awaitSpeakCompletion(true) 的 Android 上，speak 会等待完成返回
        _isSpeaking = false;
        _processNextInQueue(volume: volume);
      }
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
