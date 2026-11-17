import 'package:flutter/material.dart';
import '../../models/checkpoint.dart';
import '../../models/timer_session.dart';
import '../../services/audio_chime_service.dart';
import '../../services/tts_service.dart';

/// 应用内 5 级独立音量调节弹窗
class VolumeSettingDialog extends StatefulWidget {
  final double currentVolume;
  final ValueChanged<double> onVolumeChanged;

  const VolumeSettingDialog({
    super.key,
    required this.currentVolume,
    required this.onVolumeChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required double currentVolume,
    required ValueChanged<double> onVolumeChanged,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => VolumeSettingDialog(
        currentVolume: currentVolume,
        onVolumeChanged: onVolumeChanged,
      ),
    );
  }

  @override
  State<VolumeSettingDialog> createState() => _VolumeSettingDialogState();
}

class _VolumeSettingDialogState extends State<VolumeSettingDialog> {
  late VolumeLevel _level;
  final AudioChimeService _chimeService = AudioChimeService();
  final TtsService _ttsService = TtsService();

  @override
  void initState() {
    super.initState();
    _level = VolumeLevel.fromScalar(widget.currentVolume);
  }

  IconData _getVolumeIcon(VolumeLevel level) {
    switch (level) {
      case VolumeLevel.level1:
        return Icons.volume_mute;
      case VolumeLevel.level2:
      case VolumeLevel.level3:
        return Icons.volume_down;
      case VolumeLevel.level4:
      case VolumeLevel.level5:
        return Icons.volume_up;
    }
  }

  void _testVolume() {
    // 立即以当前设置的等级试听铃声与语音
    _chimeService.playChime(ChimeSoundType.gentleBell, volume: _level.scalar);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        _ttsService.speak(
          '当前为第 ${_level.level} 级音量',
          volume: _level.scalar,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 6,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 头部标题
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    _getVolumeIcon(_level),
                    size: 20,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '应用内音量设置',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '独立于系统音量 · 5个等级',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 说明说明
            Text(
              '仅调节 SnoozeDD 内部的铃声与播报音量，方便在播放音乐或佩戴耳机时保持平衡。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),

            // 5 级滑块选择
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _level.label,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        '第 ${_level.level} / 5 级',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _level.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    ),
                    child: Slider(
                      value: _level.level.toDouble(),
                      min: 1.0,
                      max: 5.0,
                      divisions: 4,
                      onChanged: (val) {
                        setState(() {
                          _level = VolumeLevel.values[val.toInt() - 1];
                        });
                      },
                    ),
                  ),
                  // 1 ~ 5 挡位文字刻度
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [1, 2, 3, 4, 5].map((lvl) {
                      final isSelected = _level.level == lvl;
                      return Text(
                        '$lvl级',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 试听按钮
            OutlinedButton.icon(
              icon: const Icon(Icons.volume_up, size: 18),
              label: Text('试听第 ${_level.level} 级音量效果'),
              onPressed: _testVolume,
            ),
            const SizedBox(height: 18),

            // 底部操作
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    widget.onVolumeChanged(_level.scalar);
                    Navigator.of(context).pop();
                  },
                  child: const Text('确定'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
