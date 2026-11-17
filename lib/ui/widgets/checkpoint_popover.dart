import 'package:flutter/material.dart';
import '../../models/checkpoint.dart';
import '../../services/audio_chime_service.dart';
import '../../services/tts_service.dart';

/// 节点轻量编辑卡片弹窗
class CheckpointPopover extends StatefulWidget {
  final Checkpoint checkpoint;
  final int totalDurationSeconds;
  final ValueChanged<Checkpoint> onUpdated;
  final VoidCallback onDeleted;

  const CheckpointPopover({
    super.key,
    required this.checkpoint,
    required this.totalDurationSeconds,
    required this.onUpdated,
    required this.onDeleted,
  });

  /// 弹出展示节点编辑卡片
  static Future<void> show(
    BuildContext context, {
    required Checkpoint checkpoint,
    required int totalDurationSeconds,
    required ValueChanged<Checkpoint> onUpdated,
    required VoidCallback onDeleted,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => CheckpointPopover(
        checkpoint: checkpoint,
        totalDurationSeconds: totalDurationSeconds,
        onUpdated: onUpdated,
        onDeleted: onDeleted,
      ),
    );
  }

  @override
  State<CheckpointPopover> createState() => _CheckpointPopoverState();
}

class _CheckpointPopoverState extends State<CheckpointPopover> {
  late TextEditingController _textController;
  late bool _isEnabled;
  late ChimeSoundType _chimeSound;

  final AudioChimeService _chimeService = AudioChimeService();
  final TtsService _ttsService = TtsService();

  @override
  void initState() {
    super.initState();
    _textController =
        TextEditingController(text: widget.checkpoint.announcementText);
    _isEnabled = widget.checkpoint.isEnabled;
    _chimeSound = widget.checkpoint.chimeSound;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _formatTime() {
    final mins = widget.checkpoint.offsetSeconds ~/ 60;
    final secs = widget.checkpoint.offsetSeconds % 60;
    final formatted = secs == 0 ? '$mins 分钟' : '$mins 分 $secs 秒';
    if (widget.checkpoint.triggerType == CheckpointTriggerType.remaining) {
      return '剩余 $formatted 处触发';
    } else {
      return '进行至 $formatted 处触发';
    }
  }

  void _testAudio() {
    final text = _textController.text.trim();
    final speakText = text.isNotEmpty ? text : '这是一条测试播报';
    _chimeService.playChime(_chimeSound);
    final delay = _chimeSound != ChimeSoundType.none
        ? const Duration(milliseconds: 700)
        : Duration.zero;
    Future.delayed(delay, () {
      if (mounted) {
        _ttsService.speak(speakText);
      }
    });
  }

  void _saveChanges() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final updated = widget.checkpoint.copyWith(
      announcementText: text,
      isEnabled: _isEnabled,
      chimeSound: _chimeSound,
    );
    widget.onUpdated(updated);
    Navigator.of(context).pop();
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除此节点？'),
        content: Text('确认删除「${widget.checkpoint.announcementText}」节点？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onDeleted();
              Navigator.of(context).pop();
            },
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 顶部标题与关闭
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _isEnabled
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.notifications_active,
                    size: 16,
                    color: _isEnabled
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '节点设置',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTime(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isEnabled,
                  onChanged: (val) {
                    setState(() {
                      _isEnabled = val;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 播报文案编辑
            Text(
              '语音播报文案：',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                hintText: '输入到点播报文案',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 14),
            // 提示音下拉
            Text(
              '伴随提示音：',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<ChimeSoundType>(
              initialValue: _chimeSound,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(
                  value: ChimeSoundType.gentleBell,
                  child: Text('轻柔风铃 (Gentle Bell)'),
                ),
                DropdownMenuItem(
                  value: ChimeSoundType.waterDrop,
                  child: Text('清澈水滴 (Water Drop)'),
                ),
                DropdownMenuItem(
                  value: ChimeSoundType.singingBowl,
                  child: Text('静心颂钵 (Singing Bowl)'),
                ),
                DropdownMenuItem(
                  value: ChimeSoundType.none,
                  child: Text('无提示音 (仅 TTS)'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _chimeSound = val;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.volume_up, size: 18),
              label: const Text('测试声音 (试听播报)'),
              onPressed: _testAudio,
            ),
            const SizedBox(height: 16),
            // 底部操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: theme.colorScheme.error),
                  tooltip: '删除此节点',
                  onPressed: _confirmDelete,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _saveChanges,
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
