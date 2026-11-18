import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';

/// 高级感配色、模式与微质感个性化配置弹窗
class ThemeSettingDialog extends StatelessWidget {
  const ThemeSettingDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const ThemeSettingDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ThemeScope.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      backgroundColor: theme.colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 顶栏标题
              Row(
                children: [
                  Icon(
                    Icons.palette_outlined,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '个性化风格与质感',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 1. 配色方案选择
              Text(
                '配色方案',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPaletteCard(
                      context: context,
                      palette: AppPalette.warmUmber,
                      isSelected: controller.palette == AppPalette.warmUmber,
                      primaryPreview: isDark
                          ? AppTheme.warmDarkPrimary
                          : AppTheme.warmLightPrimary,
                      accentPreview: isDark
                          ? AppTheme.warmDarkAccent
                          : AppTheme.warmLightAccent,
                      bgPreview: isDark
                          ? AppTheme.warmDarkScaffold
                          : AppTheme.warmLightScaffold,
                      onTap: () => controller.setPalette(AppPalette.warmUmber),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPaletteCard(
                      context: context,
                      palette: AppPalette.pineSlate,
                      isSelected: controller.palette == AppPalette.pineSlate,
                      primaryPreview: isDark
                          ? AppTheme.pineDarkPrimary
                          : AppTheme.pineLightPrimary,
                      accentPreview: isDark
                          ? AppTheme.pineDarkAccent
                          : AppTheme.pineLightAccent,
                      bgPreview: isDark
                          ? AppTheme.pineDarkScaffold
                          : AppTheme.pineLightScaffold,
                      onTap: () => controller.setPalette(AppPalette.pineSlate),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. 明暗模式选择
              Text(
                '亮度模式',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text('跟随系统'),
                    icon: Icon(Icons.brightness_auto, size: 18),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text('亮色'),
                    icon: Icon(Icons.light_mode, size: 18),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text('暗色'),
                    icon: Icon(Icons.dark_mode, size: 18),
                  ),
                ],
                selected: {controller.themeMode},
                onSelectionChanged: (Set<ThemeMode> newSelection) {
                  controller.setThemeMode(newSelection.first);
                },
                style: SegmentedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 3. 物理微质感纹理
              Text(
                '表面微质感 (无渐变)',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTextureChip(
                    context: context,
                    style: TextureStyle.grain,
                    icon: Icons.grain,
                    isSelected: controller.textureStyle == TextureStyle.grain,
                    onTap: () => controller.setTextureStyle(TextureStyle.grain),
                  ),
                  const SizedBox(width: 8),
                  _buildTextureChip(
                    context: context,
                    style: TextureStyle.dots,
                    icon: Icons.blur_on,
                    isSelected: controller.textureStyle == TextureStyle.dots,
                    onTap: () => controller.setTextureStyle(TextureStyle.dots),
                  ),
                  const SizedBox(width: 8),
                  _buildTextureChip(
                    context: context,
                    style: TextureStyle.none,
                    icon: Icons.check_box_outline_blank,
                    isSelected: controller.textureStyle == TextureStyle.none,
                    onTap: () => controller.setTextureStyle(TextureStyle.none),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaletteCard({
    required BuildContext context,
    required AppPalette palette,
    required bool isSelected,
    required Color primaryPreview,
    required Color accentPreview,
    required Color bgPreview,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 颜色预览小圆点
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: primaryPreview,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: accentPreview,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              palette.label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              palette.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextureChip({
    required BuildContext context,
    required TextureStyle style,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                style.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
