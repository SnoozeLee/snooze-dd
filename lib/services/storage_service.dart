import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timer_session.dart';
import '../ui/theme/app_theme.dart';

/// 本地轻量配置持久化服务
class StorageService {
  static const String _keyLatestSession = 'snooze_dd_latest_session';
  static const String _keyThemePalette = 'snooze_dd_theme_palette';
  static const String _keyThemeMode = 'snooze_dd_theme_mode';
  static const String _keyTextureStyle = 'snooze_dd_texture_style';

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

  /// 保存配色方案
  static Future<bool> savePalette(AppPalette palette) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keyThemePalette, palette.name);
    } catch (e) {
      debugPrint('Failed to save palette: $e');
      return false;
    }
  }

  /// 加载配色方案 (默认岩茶金石)
  static Future<AppPalette> loadPalette() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getString(_keyThemePalette);
      if (val != null) {
        return AppPalette.values.firstWhere(
          (p) => p.name == val,
          orElse: () => AppPalette.warmUmber,
        );
      }
    } catch (e) {
      debugPrint('Failed to load palette: $e');
    }
    return AppPalette.warmUmber;
  }

  /// 保存主题明暗模式
  static Future<bool> saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keyThemeMode, mode.name);
    } catch (e) {
      debugPrint('Failed to save theme mode: $e');
      return false;
    }
  }

  /// 加载主题明暗模式 (默认跟随系统)
  static Future<ThemeMode> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getString(_keyThemeMode);
      if (val != null) {
        return ThemeMode.values.firstWhere(
          (m) => m.name == val,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e) {
      debugPrint('Failed to load theme mode: $e');
    }
    return ThemeMode.system;
  }

  /// 保存背景微质感纹理类型
  static Future<bool> saveTextureStyle(TextureStyle style) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keyTextureStyle, style.name);
    } catch (e) {
      debugPrint('Failed to save texture style: $e');
      return false;
    }
  }

  /// 加载背景微质感纹理类型 (默认和纸砂石微粒)
  static Future<TextureStyle> loadTextureStyle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getString(_keyTextureStyle);
      if (val != null) {
        return TextureStyle.values.firstWhere(
          (s) => s.name == val,
          orElse: () => TextureStyle.grain,
        );
      }
    } catch (e) {
      debugPrint('Failed to load texture style: $e');
    }
    return TextureStyle.grain;
  }
}
