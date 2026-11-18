import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 实体级微质感纯色背景包装组件 (严格 0 渐变，通过微微粒或精密几何点阵传递工业物理触感)
class TextureBackground extends StatelessWidget {
  final TextureStyle style;
  final Widget child;

  const TextureBackground({
    super.key,
    required this.style,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (style == TextureStyle.none) {
      return child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final particleColor = isDark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF000000);

    return RepaintBoundary(
      child: CustomPaint(
        foregroundPainter: _TexturePainter(
          style: style,
          particleColor: particleColor,
          isDark: isDark,
        ),
        child: child,
      ),
    );
  }
}

class _TexturePainter extends CustomPainter {
  final TextureStyle style;
  final Color particleColor;
  final bool isDark;

  // 预生成确定性的伪随机噪点偏移与大小，避免每帧重复随机计算
  static final List<_GrainPoint> _cachedPoints = _generateGrainPoints();

  const _TexturePainter({
    required this.style,
    required this.particleColor,
    required this.isDark,
  });

  static List<_GrainPoint> _generateGrainPoints() {
    final list = <_GrainPoint>[];
    final random = Random(42); // 固定种子以保证渲染一致性
    // 生成覆盖 256x256 单元格的确定性微颗粒 (增强可见度与自然手感)
    for (int i = 0; i < 340; i++) {
      list.add(_GrainPoint(
        dx: random.nextDouble() * 256.0,
        dy: random.nextDouble() * 256.0,
        radius: 0.9 + random.nextDouble() * 0.9,
        alphaFactor: 0.5 + random.nextDouble() * 0.5,
      ));
    }
    return list;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (style == TextureStyle.none || size.width <= 0 || size.height <= 0) {
      return;
    }

    final paint = Paint()..style = PaintingStyle.fill;

    if (style == TextureStyle.dots) {
      // 精密几何打孔点阵 (加粗加深至清晰笃定)
      const spacing = 16.0;
      final dotAlpha = isDark ? 0.13 : 0.10;
      paint.color = particleColor.withValues(alpha: dotAlpha);

      for (double x = spacing / 2; x < size.width; x += spacing) {
        for (double y = spacing / 2; y < size.height; y += spacing) {
          canvas.drawCircle(Offset(x, y), 1.05, paint);
        }
      }
      return;
    }

    if (style == TextureStyle.grain) {
      // 和纸 / 哑光砂石微粒 (适度加深至 8%~12%，维持零渐变高级感)
      final baseAlpha = isDark ? 0.11 : 0.085;
      const tileSize = 256.0;

      for (double tileX = 0; tileX < size.width; tileX += tileSize) {
        for (double tileY = 0; tileY < size.height; tileY += tileSize) {
          for (final pt in _cachedPoints) {
            final x = tileX + pt.dx;
            final y = tileY + pt.dy;
            if (x < size.width && y < size.height) {
              paint.color = particleColor.withValues(
                alpha: (baseAlpha * pt.alphaFactor).clamp(0.04, 0.14),
              );
              canvas.drawCircle(Offset(x, y), pt.radius, paint);
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TexturePainter oldDelegate) {
    return oldDelegate.style != style ||
        oldDelegate.particleColor != particleColor ||
        oldDelegate.isDark != isDark;
  }
}

class _GrainPoint {
  final double dx;
  final double dy;
  final double radius;
  final double alphaFactor;

  const _GrainPoint({
    required this.dx,
    required this.dy,
    required this.radius,
    required this.alphaFactor,
  });
}
