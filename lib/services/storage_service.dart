import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timer_session.dart';

/// 本地轻量配置持久化服务
class StorageService {
  static const String _keyLatestSession = 'snooze_dd_latest_session';

  /// 持久化保存当前计时会话与节点配置
  static Future<bool> saveSession(TimerSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(session.toJson());
      return await prefs.setString(_keyLatestSession, jsonString);
    } catch (e) {
      debugPrint('Failed to save session to storage: $e');
      return false;
    }
  }

  /// 加载上一次保存的计时会话，无缓存时回退到默认番茄钟
  static Future<TimerSession> loadLatestSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyLatestSession);
      if (jsonString != null && jsonString.isNotEmpty) {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        return TimerSession.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('Failed to load session, falling back to default: $e');
    }
    return TimerSession.defaultPomodoro();
  }
}
