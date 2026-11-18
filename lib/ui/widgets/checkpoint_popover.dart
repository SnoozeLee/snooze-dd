import 'package:flutter/material.dart';
import '../../models/checkpoint.dart';
import '../../services/audio_chime_service.dart';
import '../../services/tts_service.dart';

/// 统一的节点添加与编辑配置卡片弹窗
class CheckpointPopover extends StatefulWidget {
  final Checkpoint? checkpoint;
  final int totalDurationSeconds;
  final double volume;
  final ValueChanged<Checkpoint> onSaved;
  final VoidCallback? onDeleted;

  const CheckpointPopover({
    super.key,
    this.checkpoint,
    required this.totalDurationSeconds,
    this.volume = 0.8,
    required this.onSaved,
    this.onDeleted,
  });

  /// 弹出展示节点配置卡片 (checkpoint 为 null 时为添加模式，非 null 时为编辑模式)
  static Future<void> show(
    BuildContext context, {
    Checkpoint? checkpoint,
    required int totalDurationSeconds,
    double volume = 0.8,
    ValueChanged<Checkpoint>? onSaved,
    ValueChanged<Checkpoint>? onUpdated,
    VoidCallback? onDeleted,
  }) {
    final callback = onSaved ?? onUpdated;
    assert(callback != null, 'Either onSaved or onUpdated must be provided');

    return showDialog(
      context: context,
      builder: (ctx) => CheckpointPopover(
        checkpoint: checkpoint,
        totalDurationSeconds: totalDurationSeconds,
        volume: volume,
        onSaved: callback!,
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
  late int _offsetMinutes;
  late CheckpointTriggerType _triggerType;

  final AudioChimeService _chimeService = AudioChimeService();
  final TtsService _ttsService = TtsService();

  bool get isAddMode => widget.checkpoint == null;

  @override
  void initState() {
    super.initState();
    _triggerType =
        widget.checkpoint?.triggerType ?? CheckpointTriggerType.remaining;

    final defaultText = _triggerType == CheckpointTriggerType.remaining
        ? '还有五分钟'
        : '已经进行五分钟';
    _textController = TextEditingController(
      text: widget.checkpoint?.announcementText ?? defaultText,
    );

    _isEnabled = widget.checkpoint?.isEnabled ?? true;
    _chimeSound = widget.checkpoint?.chimeSound ?? ChimeSoundType.gentleBell;

    final totalMins = widget.totalDurationSeconds ~/ 60;
    final maxMins = totalMins > 1 ? totalMins - 1 : 1;

    final initialMins = widget.checkpoint != null
        ? (widget.checkpoint!.offsetSeconds / 60).round()
        : 5;
    _offsetMinutes = initialMins.clamp(1, maxMins);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _formatTime() {
    if (_triggerType == CheckpointTriggerType.remaining) {
      return '剩余 $_offsetMinutes 分钟处播报';
    } else {
      return '进行至 $_offsetMinutes 分钟处播报';
    }
  }

  void _testAudio() {
    final text = _textController.text.trim();
    final speakText = text.isNotEmpty ? text : '这是一条测试播报';
    _chimeService.playChime(_chimeSound, volume: widget.volume);
    final delay = _chimeSound != ChimeSoundType.none
        ? const Duration(milliseconds: 700)
        : Duration.zero;
    Future.delayed(delay, () {
      if (mounted) {
        _ttsService.speak(speakText, volume: widget.volume);
      }
    });
  }

  void _saveChanges() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    if (isAddMode) {
      final newCp = Checkpoint.create(
        offsetSeconds: _offsetMinutes * 60,
        triggerType: _triggerType,
        announcementText: text,
        chimeSound: _chimeSound,
        isEnabled: _isEnabled,
      );
      widget.onSaved(newCp);
    } else {
      final updated = widget.checkpoint!.copyWith(
        offsetSeconds: _offsetMinutes * 60,
        triggerType: _triggerType,
        announcementText: text,
        isEnabled: _isEnabled,
        chimeSound: _chimeSound,
      );
      widget.onSaved(updated);
    }

    Navigator.of(context).pop();
  }

  void _confirmDelete() {
    if (widget.checkpoint == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除此节点？'),
        content: Text('确认删除「${widget.checkpoint!.announcementText}」节点？'),
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
              widget.onDeleted?.call();
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
    final totalMins = widget.totalDurationSeconds ~/ 60;
    final maxM = totalMins > 1 ? totalMins - 1 : 1;

    // 智能生成分钟候选项 (优先常用刻度，再补齐当前选值)
    final candidateSet = <int>{};
    for (final m in [1, 2, 3, 5, 10, 15, 20, 25, 30, 45, 60]) {
      if (m <= maxM) candidateSet.add(m);
    }
    candidateSet.add(_offsetMinutes);
    final minuteOptions = candidateSet.toList()..sort();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.outline, width: 1),
      ),
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380, maxHeight: 580),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. 顶部标题栏 (固定在顶部)
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: (isAddMode || _isEnabled)
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      isAddMode
                          ? Icons.add_alarm
                          : Icons.notifications_active,
                      size: 18,
                      color: (isAddMode || _isEnabled)
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
                          isAddMode ? '添加播报节点' : '节点设置',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (!isAddMode)
                          Text(
                            _formatTime(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!isAddMode)
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
              const SizedBox(height: 14),

              // 2. 表单配置区域 (自适应可滚动)
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 触发基准类型选择 (统一保留 SegmentedButton 倒计/正计切换风格)
                      Text(
                        '触发基准类型：',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<CheckpointTriggerType>(
                        segments: const [
                          ButtonSegment(
                            value: CheckpointTriggerType.remaining,
                            label: Text('倒计剩余'),
                            icon: Icon(Icons.timer_outlined, size: 16),
                          ),
                          ButtonSegment(
                            value: CheckpointTriggerType.elapsed,
                            label: Text('正计进行'),
                            icon: Icon(Icons.hourglass_top, size: 16),
                          ),
                        ],
                        selected: {_triggerType},
                        onSelectionChanged: (set) {
                          setState(() {
                            final newType = set.first;
                            if (newType != _triggerType) {
                              _triggerType = newType;
                              if (isAddMode) {
                                if (_triggerType ==
                                        CheckpointTriggerType.elapsed &&
                                    _textController.text == '还有五分钟') {
                                  _textController.text = '已经进行五分钟';
                                } else if (_triggerType ==
                                        CheckpointTriggerType.remaining &&
                                    _textController.text == '已经进行五分钟') {
                                  _textController.text = '还有五分钟';
                                }
                              }
                            }
                          });
                        },
                        style: SegmentedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 触发分钟选择
                      Text(
                        _triggerType == CheckpointTriggerType.remaining
                            ? '触发时间（剩余分钟）：'
                            : '触发时间（进行至分钟）：',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        initialValue: _offsetMinutes,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        items: minuteOptions.map((m) {
                          return DropdownMenuItem<int>(
                            value: m,
                            child: Text(
                              _triggerType == CheckpointTriggerType.remaining
                                  ? '剩余 $m 分钟'
                                  : '进行至 $m 分钟',
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _offsetMinutes = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 14),

                      // 语音播报文案
                      Text(
                        '自定义语音播报文案：',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          isDense: true,
                          hintText: isAddMode
                              ? '如：还有五分钟，请放缓呼吸'
                              : '输入到点播报文案',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),

                      // 伴随提示音选择
                      Text(
                        '伴随提示音：',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
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

                      // 声音试听按钮
                      OutlinedButton.icon(
                        icon: const Icon(Icons.volume_up, size: 18),
                        label: const Text('测试声音 (试听伴音与播报)'),
                        onPressed: _testAudio,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. 底部操作按钮 (固定在底部，无需滚动即可操作)
              Row(
                children: [
                  if (!isAddMode)
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: theme.colorScheme.error),
                      tooltip: '删除此节点',
                      onPressed: _confirmDelete,
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _saveChanges,
                    child: Text(isAddMode ? '添加' : '保存'),
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
