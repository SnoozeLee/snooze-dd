import 'package:flutter/material.dart';

/// 优雅柔和的环形计时表盘组件
class TimerDial extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final double progress;
  final bool isRunning;
  final String statusText;

  const TimerDial({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.progress,
    required this.isRunning,
    this.statusText = '',
  });

  String _formatTime(int totalSecs) {
    final minutes = totalSecs ~/ 60;
    final seconds = totalSecs % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Center(
      child: SizedBox(
        width: 260,
        height: 260,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 背景圆环
            SizedBox(
              width: 250,
              height: 250,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
                valueColor: AlwaysStoppedAnimation<Color>(
                  primaryColor.withValues(alpha: 0.12),
                ),
              ),
            ),
            // 实时倒计进度环
            SizedBox(
              width: 250,
              height: 250,
              child: CircularProgressIndicator(
                value: 1.0 - progress,
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
            // 中间时间大字
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(remainingSeconds),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  statusText.isNotEmpty
                      ? statusText
                      : (isRunning ? '专注进行中' : '点击开始'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
