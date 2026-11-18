import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/checkpoint.dart';
import '../theme/app_theme.dart';

/// 节点在表盘上的几何与展示信息
class DialMarkerInfo {
  final Checkpoint checkpoint;
  final double ratio;
  final double angle; // 弧度：-pi/2 到 3*pi/2
  final bool showLabel;
  final String label;

  const DialMarkerInfo({
    required this.checkpoint,
    required this.ratio,
    required this.angle,
    required this.showLabel,
    required this.label,
  });
}

/// 表盘节点标记计算工具类
class DialMarkerHelper {
  /// 计算所有 Checkpoint 在圆环上的角度与标签防重叠
  static List<DialMarkerInfo> calculateMarkers({
    required List<Checkpoint> checkpoints,
    required int totalDurationSeconds,
  }) {
    if (totalDurationSeconds <= 0 || checkpoints.isEmpty) {
      return const [];
    }

    final rawList = <DialMarkerInfo>[];

    for (final cp in checkpoints) {
      double ratio;
      if (cp.triggerType == CheckpointTriggerType.remaining) {
        ratio = (cp.offsetSeconds / totalDurationSeconds).clamp(0.0, 1.0);
      } else {
        ratio = ((totalDurationSeconds - cp.offsetSeconds) / totalDurationSeconds)
            .clamp(0.0, 1.0);
      }

      // -pi/2 为 12 点钟方向，顺时针扫射
      final angle = -pi / 2 + ratio * 2 * pi;

      final mins = cp.offsetSeconds ~/ 60;
      final secs = cp.offsetSeconds % 60;
      final timeStr = secs == 0
          ? '${mins}m'
          : '$mins:${secs.toString().padLeft(2, '0')}';
      // 区分正向进行 (▶) 与倒计剩余 (⏳)
      final prefix = cp.triggerType == CheckpointTriggerType.elapsed ? '▶ ' : '⏳ ';
      final label = '$prefix$timeStr';

      rawList.add(DialMarkerInfo(
        checkpoint: cp,
        ratio: ratio,
        angle: angle,
        showLabel: true,
        label: label,
      ));
    }

    // 按角度排序进行碰撞检测
    rawList.sort((a, b) => a.angle.compareTo(b.angle));

    final result = <DialMarkerInfo>[];
    const minAngleDiff = 15.0 * (pi / 180.0); // 15度防重叠阈值

    for (int i = 0; i < rawList.length; i++) {
      final current = rawList[i];
      bool overlap = false;

      // 检查与前一个节点的角度差
      if (i > 0 && (current.angle - rawList[i - 1].angle).abs() < minAngleDiff) {
        overlap = true;
      }
      // 检查与后一个节点的角度差
      if (i < rawList.length - 1 &&
          (rawList[i + 1].angle - current.angle).abs() < minAngleDiff) {
        overlap = true;
      }

      result.add(DialMarkerInfo(
        checkpoint: current.checkpoint,
        ratio: current.ratio,
        angle: current.angle,
        showLabel: !overlap,
        label: current.label,
      ));
    }

    return result;
  }
}

/// 优雅柔和的环形计时表盘组件（支持圆弧节点可视化与点击）
class TimerDial extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final double progress;
  final bool isRunning;
  final String statusText;
  final List<Checkpoint> checkpoints;
  final Set<String> triggeredCheckpointIds;
  final ValueChanged<Checkpoint>? onCheckpointTap;
  final VoidCallback? onDialCenterTap;

  const TimerDial({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.progress,
    required this.isRunning,
    this.statusText = '',
    this.checkpoints = const [],
    this.triggeredCheckpointIds = const {},
    this.onCheckpointTap,
    this.onDialCenterTap,
  });

  String _formatTime(int totalSecs) {
    final minutes = totalSecs ~/ 60;
    final seconds = totalSecs % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  void _handleTap(TapUpDetails details, BuildContext context, double size) {
    if (checkpoints.isEmpty) {
      onDialCenterTap?.call();
      return;
    }

    final center = Offset(size / 2, size / 2);
    final touchOffset = details.localPosition;
    final markers = DialMarkerHelper.calculateMarkers(
      checkpoints: checkpoints,
      totalDurationSeconds: totalSeconds,
    );

    const radius = 105.0;
    Checkpoint? tappedCheckpoint;
    double minDistance = double.infinity;

    for (final marker in markers) {
      final markerX = center.dx + radius * cos(marker.angle);
      final markerY = center.dy + radius * sin(marker.angle);
      final markerOffset = Offset(markerX, markerY);

      final distance = (touchOffset - markerOffset).distance;
      if (distance < 28.0 && distance < minDistance) {
        minDistance = distance;
        tappedCheckpoint = marker.checkpoint;
      }
    }

    if (tappedCheckpoint != null) {
      onCheckpointTap?.call(tappedCheckpoint);
    } else {
      // 若没有点击在节点上，并且在表盘中心区域，则触发中心点击事件
      final distToCenter = (touchOffset - center).distance;
      if (distToCenter < radius * 0.75) {
        onDialCenterTap?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dialExt = theme.extension<DialThemeExtension>();

    final primaryColor = dialExt?.primaryArcColor ?? theme.colorScheme.primary;
    final trackColor = dialExt?.trackColor ?? theme.colorScheme.outlineVariant;
    final accentColor = dialExt?.accentMarkerColor ?? theme.colorScheme.secondary;
    final badgeColor = dialExt?.markerBadgeColor ?? theme.colorScheme.surfaceContainerHighest;
    final badgeTextColor = dialExt?.markerTextColor ?? theme.colorScheme.onSurface;

    const dialSize = 280.0;

    final markers = DialMarkerHelper.calculateMarkers(
      checkpoints: checkpoints,
      totalDurationSeconds: totalSeconds,
    );

    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) => _handleTap(details, context, dialSize),
        child: SizedBox(
          width: dialSize,
          height: dialSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // CustomPaint 绘制高对比背景弧、倒计进度弧和各节点标记
              CustomPaint(
                size: const Size(dialSize, dialSize),
                painter: _DialPainter(
                  progress: progress,
                  primaryColor: primaryColor,
                  trackColor: trackColor,
                  accentColor: accentColor,
                  badgeColor: badgeColor,
                  badgeTextColor: badgeTextColor,
                  markers: markers,
                  triggeredIds: triggeredCheckpointIds,
                  textTheme: theme.textTheme,
                ),
              ),
              // 中间时间大字：加粗等宽，高对比清晰易读
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(remainingSeconds),
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontSize: 54,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      color: theme.colorScheme.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    statusText.isNotEmpty
                        ? statusText
                        : (isRunning ? '专注进行中' : '点击开始'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color trackColor;
  final Color accentColor;
  final Color badgeColor;
  final Color badgeTextColor;
  final List<DialMarkerInfo> markers;
  final Set<String> triggeredIds;
  final TextTheme textTheme;

  const _DialPainter({
    required this.progress,
    required this.primaryColor,
    required this.trackColor,
    required this.accentColor,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.markers,
    required this.triggeredIds,
    required this.textTheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 105.0;
    const strokeWidth = 11.0;

    // 1. 绘制底轨圆环 (实色高对比底轨，无渐变)
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. 绘制倒计时进度弧 (饱满浓郁实色弧线，两端圆润)
    final progressPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (1.0 - progress).clamp(0.0, 1.0) * 2 * pi;
    if (sweepAngle > 0.001) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }

    // 3. 绘制节点标记点及防重叠高对比标签
    for (final marker in markers) {
      final isTriggered = triggeredIds.contains(marker.checkpoint.id);
      final isEnabled = marker.checkpoint.isEnabled;

      final markerX = center.dx + radius * cos(marker.angle);
      final markerY = center.dy + radius * sin(marker.angle);
      final markerCenter = Offset(markerX, markerY);

      // 节点圆点样式
      Color dotColor;
      Color borderColor = trackColor;

      if (!isEnabled) {
        dotColor = trackColor;
        borderColor = trackColor.withValues(alpha: 0.5);
      } else if (isTriggered) {
        dotColor = Colors.grey.shade400;
        borderColor = badgeColor;
      } else {
        dotColor = accentColor;
        borderColor = badgeTextColor;
      }

      // 绘制外圈高对比隔离环
      canvas.drawCircle(
        markerCenter,
        7.5,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.fill,
      );

      // 绘制节点内圆
      canvas.drawCircle(
        markerCenter,
        5.2,
        Paint()
          ..color = dotColor
          ..style = PaintingStyle.fill,
      );

      // 若已触发，绘制小勾标记
      if (isTriggered && isEnabled) {
        final tickPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        final p = Path()
          ..moveTo(markerCenter.dx - 2.5, markerCenter.dy)
          ..lineTo(markerCenter.dx - 0.5, markerCenter.dy + 2)
          ..lineTo(markerCenter.dx + 3, markerCenter.dy - 2);
        canvas.drawPath(p, tickPaint);
      }

      // 绘制带有实体小标牌的高清时间标签 (如 5m, 10m)
      if (marker.showLabel) {
        const labelRadius = radius + 22.0;
        final labelX = center.dx + labelRadius * cos(marker.angle);
        final labelY = center.dy + labelRadius * sin(marker.angle);
        final labelCenter = Offset(labelX, labelY);

        final labelSpan = TextSpan(
          text: marker.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isEnabled
                ? (isTriggered ? Colors.grey.shade500 : badgeTextColor)
                : Colors.grey.shade400,
            decoration: isEnabled ? null : TextDecoration.lineThrough,
          ),
        );

        final textPainter = TextPainter(
          text: labelSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        // 绘制微圆角标签标牌背景 (实色防重叠背景)
        final badgeRect = Rect.fromCenter(
          center: labelCenter,
          width: textPainter.width + 10,
          height: textPainter.height + 4,
        );
        final badgeRRect = RRect.fromRectAndRadius(badgeRect, const Radius.circular(6));

        canvas.drawRRect(
          badgeRRect,
          Paint()
            ..color = badgeColor
            ..style = PaintingStyle.fill,
        );

        canvas.drawRRect(
          badgeRRect,
          Paint()
            ..color = trackColor.withValues(alpha: 0.6)
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke,
        );

        final textOffset = Offset(
          labelX - textPainter.width / 2,
          labelY - textPainter.height / 2,
        );
        textPainter.paint(canvas, textOffset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.badgeColor != badgeColor ||
        oldDelegate.markers != markers ||
        oldDelegate.triggeredIds != triggeredIds;
  }
}
