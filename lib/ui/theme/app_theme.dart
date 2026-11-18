import 'package:flutter/material.dart';

/// 配色方案枚举
enum AppPalette {
  /// 岩茶金石：禅意温润、经典沉稳 (Warm Umber & Brass)
  warmUmber,

  /// 松烟墨青：理性克制、冷峻现代 (Pine & Slate)
  pineSlate;

  String get label {
    switch (this) {
      case AppPalette.warmUmber:
        return '岩茶金石';
      case AppPalette.pineSlate:
        return '松烟墨青';
    }
  }

  String get description {
    switch (this) {
      case AppPalette.warmUmber:
        return '禅意温润，琥珀熟茶金石';
      case AppPalette.pineSlate:
        return '理性典雅，冷杉板岩墨青';
    }
  }
}

/// 背景实体微质感枚举 (绝无颜色渐变)
enum TextureStyle {
  /// 和纸 / 哑光砂石微粒 (Washi Paper / Matte Sandstone Grain)
  grain,

  /// 精密几何打孔点阵 (Precision Stippled Dots)
  dots,

  /// 纯净无微粒
  none;

  String get label {
    switch (this) {
      case TextureStyle.grain:
        return '和纸砂石微粒';
      case TextureStyle.dots:
        return '精密几何点阵';
      case TextureStyle.none:
        return '纯净无微粒';
    }
  }
}

/// 表盘与节点高对比专属色彩拓展
@immutable
class DialThemeExtension extends ThemeExtension<DialThemeExtension> {
  final Color trackColor;
  final Color primaryArcColor;
  final Color accentMarkerColor;
  final Color markerBadgeColor;
  final Color markerTextColor;

  const DialThemeExtension({
    required this.trackColor,
    required this.primaryArcColor,
    required this.accentMarkerColor,
    required this.markerBadgeColor,
    required this.markerTextColor,
  });

  @override
  DialThemeExtension copyWith({
    Color? trackColor,
    Color? primaryArcColor,
    Color? accentMarkerColor,
    Color? markerBadgeColor,
    Color? markerTextColor,
  }) {
    return DialThemeExtension(
      trackColor: trackColor ?? this.trackColor,
      primaryArcColor: primaryArcColor ?? this.primaryArcColor,
      accentMarkerColor: accentMarkerColor ?? this.accentMarkerColor,
      markerBadgeColor: markerBadgeColor ?? this.markerBadgeColor,
      markerTextColor: markerTextColor ?? this.markerTextColor,
    );
  }

  @override
  DialThemeExtension lerp(ThemeExtension<DialThemeExtension>? other, double t) {
    if (other is! DialThemeExtension) return this;
    return DialThemeExtension(
      trackColor: Color.lerp(trackColor, other.trackColor, t) ?? trackColor,
      primaryArcColor:
          Color.lerp(primaryArcColor, other.primaryArcColor, t) ?? primaryArcColor,
      accentMarkerColor:
          Color.lerp(accentMarkerColor, other.accentMarkerColor, t) ??
              accentMarkerColor,
      markerBadgeColor:
          Color.lerp(markerBadgeColor, other.markerBadgeColor, t) ??
              markerBadgeColor,
      markerTextColor:
          Color.lerp(markerTextColor, other.markerTextColor, t) ??
              markerTextColor,
    );
  }
}

/// SnoozeDD 高级感高对比色彩系统
class AppTheme {
  // === 方案 A：岩茶金石 (Warm Umber) ===
  // 亮色
  static const Color warmLightScaffold = Color(0xFFF7F5EE);
  static const Color warmLightSurface = Color(0xFFEBE6D9);
  static const Color warmLightSurfaceContainer = Color(0xFFE2DDD0);
  static const Color warmLightOnSurface = Color(0xFF181512); // 对比度 15.2:1
  static const Color warmLightOnSurfaceVariant = Color(0xFF5C554B); // 对比度 7.1:1
  static const Color warmLightPrimary = Color(0xFF784318);
  static const Color warmLightAccent = Color(0xFFB5651D);
  static const Color warmLightOutline = Color(0xFFD6CEBE);
  static const Color warmLightTrack = Color(0xFFDDD4C2);

  // 暗色
  static const Color warmDarkScaffold = Color(0xFF121110);
  static const Color warmDarkSurface = Color(0xFF1E1C19);
  static const Color warmDarkSurfaceContainer = Color(0xFF292520);
  static const Color warmDarkOnSurface = Color(0xFFFAF6EE); // 对比度 17.8:1
  static const Color warmDarkOnSurfaceVariant = Color(0xFFA69D90); // 对比度 6.8:1
  static const Color warmDarkPrimary = Color(0xFFE59A52);
  static const Color warmDarkAccent = Color(0xFFF2A75C);
  static const Color warmDarkOutline = Color(0xFF332F2A);
  static const Color warmDarkTrack = Color(0xFF2E2A24);

  // === 方案 B：松烟墨青 (Pine & Slate) ===
  // 亮色
  static const Color pineLightScaffold = Color(0xFFF3F6F5);
  static const Color pineLightSurface = Color(0xFFE4ECE9);
  static const Color pineLightSurfaceContainer = Color(0xFFD8E2DF);
  static const Color pineLightOnSurface = Color(0xFF0E1917); // 对比度 16.4:1
  static const Color pineLightOnSurfaceVariant = Color(0xFF495E5A); // 对比度 7.3:1
  static const Color pineLightPrimary = Color(0xFF1E544B);
  static const Color pineLightAccent = Color(0xFF2E7D6F);
  static const Color pineLightOutline = Color(0xFFCAD8D4);
  static const Color pineLightTrack = Color(0xFFD0DDD9);

  // 暗色
  static const Color pineDarkScaffold = Color(0xFF0E1313);
  static const Color pineDarkSurface = Color(0xFF182120);
  static const Color pineDarkSurfaceContainer = Color(0xFF222D2B);
  static const Color pineDarkOnSurface = Color(0xFFF0F7F5); // 对比度 18.1:1
  static const Color pineDarkOnSurfaceVariant = Color(0xFF8FAAA4); // 对比度 7.5:1
  static const Color pineDarkPrimary = Color(0xFF4ECBB0);
  static const Color pineDarkAccent = Color(0xFF56DBC0);
  static const Color pineDarkOutline = Color(0xFF2B3D3A);
  static const Color pineDarkTrack = Color(0xFF202E2B);

  /// 构建完整的 Material 3 主题
  static ThemeData buildTheme({
    required AppPalette palette,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    final isWarm = palette == AppPalette.warmUmber;

    final scaffold = isWarm
        ? (isDark ? warmDarkScaffold : warmLightScaffold)
        : (isDark ? pineDarkScaffold : pineLightScaffold);

    final surface = isWarm
        ? (isDark ? warmDarkSurface : warmLightSurface)
        : (isDark ? pineDarkSurface : pineLightSurface);

    final surfaceContainer = isWarm
        ? (isDark ? warmDarkSurfaceContainer : warmLightSurfaceContainer)
        : (isDark ? pineDarkSurfaceContainer : pineLightSurfaceContainer);

    final onSurface = isWarm
        ? (isDark ? warmDarkOnSurface : warmLightOnSurface)
        : (isDark ? pineDarkOnSurface : pineLightOnSurface);

    final onSurfaceVariant = isWarm
        ? (isDark ? warmDarkOnSurfaceVariant : warmLightOnSurfaceVariant)
        : (isDark ? pineDarkOnSurfaceVariant : pineLightOnSurfaceVariant);

    final primary = isWarm
        ? (isDark ? warmDarkPrimary : warmLightPrimary)
        : (isDark ? pineDarkPrimary : pineLightPrimary);

    final onPrimary = isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF);

    final secondary = isWarm
        ? (isDark ? warmDarkAccent : warmLightAccent)
        : (isDark ? pineDarkAccent : pineLightAccent);

    final outline = isWarm
        ? (isDark ? warmDarkOutline : warmLightOutline)
        : (isDark ? pineDarkOutline : pineLightOutline);

    final track = isWarm
        ? (isDark ? warmDarkTrack : warmLightTrack)
        : (isDark ? pineDarkTrack : pineLightTrack);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: surfaceContainer,
      onPrimaryContainer: onSurface,
      secondary: secondary,
      onSecondary: onPrimary,
      secondaryContainer: surfaceContainer,
      onSecondaryContainer: onSurface,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      error: isDark ? const Color(0xFFCF6679) : const Color(0xFFB00020),
      onError: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
    );

    final dialExtension = DialThemeExtension(
      trackColor: track,
      primaryArcColor: primary,
      accentMarkerColor: secondary,
      markerBadgeColor: surfaceContainer,
      markerTextColor: onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: outline, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary.withValues(alpha: isDark ? 0.25 : 0.15),
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: TextStyle(
          color: onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: outline, width: 1),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      extensions: [dialExtension],
    );
  }
}
