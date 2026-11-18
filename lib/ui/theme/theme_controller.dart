import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import 'app_theme.dart';

/// 全局主题与微质感状态控制器
class ThemeController extends ChangeNotifier {
  AppPalette _palette = AppPalette.warmUmber;
  ThemeMode _themeMode = ThemeMode.system;
  TextureStyle _textureStyle = TextureStyle.grain;

  AppPalette get palette => _palette;
  ThemeMode get themeMode => _themeMode;
  TextureStyle get textureStyle => _textureStyle;

  ThemeData get lightTheme => AppTheme.buildTheme(
        palette: _palette,
        brightness: Brightness.light,
      );

  ThemeData get darkTheme => AppTheme.buildTheme(
        palette: _palette,
        brightness: Brightness.dark,
      );

  /// 初始化并从本地缓存读取配置
  Future<void> init() async {
    _palette = await StorageService.loadPalette();
    _themeMode = await StorageService.loadThemeMode();
    _textureStyle = await StorageService.loadTextureStyle();
    notifyListeners();
  }

  /// 切换配色方案 (岩茶金石 / 松烟墨青)
  Future<void> setPalette(AppPalette palette) async {
    if (_palette == palette) return;
    _palette = palette;
    notifyListeners();
    await StorageService.savePalette(palette);
  }

  /// 切换明暗模式 (跟随系统 / 亮色 / 暗色)
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await StorageService.saveThemeMode(mode);
  }

  /// 切换背景微质感 (和纸微粒 / 精密点阵 / 纯净)
  Future<void> setTextureStyle(TextureStyle style) async {
    if (_textureStyle == style) return;
    _textureStyle = style;
    notifyListeners();
    await StorageService.saveTextureStyle(style);
  }
}

/// 注入 ThemeController 到 Widget 树顶层的 InheritedNotifier
class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'No ThemeScope found in context');
    return scope!.notifier!;
  }
}
