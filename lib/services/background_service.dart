import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 移动端后台保活与前台通知服务
class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  static const MethodChannel _channel =
      MethodChannel('com.snoozedd.snooze_dd/background_service');

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  /// 启动前台常驻服务与 WakeLock 保活
  Future<void> start({
    String title = '专注计时中',
    String content = '保持专注，稍后将按预定节点为您提醒...',
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('startForegroundService', {
        'title': title,
        'content': content,
      });
      _isRunning = true;
    } catch (e) {
      debugPrint('BackgroundService start error: $e');
    }
  }

  /// 更新前台常驻通知中的显示内容
  Future<void> update({
    required String title,
    required String content,
  }) async {
    if (kIsWeb || !Platform.isAndroid || !_isRunning) return;
    try {
      await _channel.invokeMethod('updateForegroundService', {
        'title': title,
        'content': content,
      });
    } catch (e) {
      debugPrint('BackgroundService update error: $e');
    }
  }

  /// 停止前台服务并释放 WakeLock
  Future<void> stop() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('stopForegroundService');
      _isRunning = false;
    } catch (e) {
      debugPrint('BackgroundService stop error: $e');
    }
  }
}
