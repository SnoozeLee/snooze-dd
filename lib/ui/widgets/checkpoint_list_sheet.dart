import 'package:flutter/material.dart';
import '../../models/checkpoint.dart';
import '../../services/audio_chime_service.dart';
import '../../services/tts_service.dart';
import 'checkpoint_popover.dart';

/// 多节点播报配置弹窗面板
class CheckpointListSheet extends StatefulWidget {
  final List<Checkpoint> checkpoints;
  final int totalDurationSeconds;
  final ValueChanged<List<Checkpoint>> onCheckpointsChanged;

  const CheckpointListSheet({
    super.key,
    required this.checkpoints,
    required this.totalDurationSeconds,
    required this.onCheckpointsChanged,
  });

  @override
  State<CheckpointListSheet> createState() => _CheckpointListSheetState();
}

class _CheckpointListSheetState extends State<CheckpointListSheet> {
  late List<Checkpoint> _list;
  final AudioChimeService _chimeService = AudioChimeService();
  final TtsService _ttsService = TtsService();

  void _testAudio(Checkpoint cp) {
    _chimeService.playChime(cp.chimeSound);
    final delay = cp.chimeSound != ChimeSoundType.none
        ? const Duration(milliseconds: 700)
        : Duration.zero;
    Future.delayed(delay, () {
      if (mounted) {
        _ttsService.speak(cp.announcementText);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.checkpoints);
  }

  void _showAddDialog() {
    final textController = TextEditingController(text: '还有五分钟');
    int offsetMinutes = 5;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加播报节点'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('触发时间（剩余分钟）：', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: offsetMinutes,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [1, 2, 3, 5, 10, 15, 20, 30]
                  .where((m) => m * 60 < widget.totalDurationSeconds)
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text('剩余 $m 分钟'),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) offsetMinutes = val;
              },
            ),
            const SizedBox(height: 16),
            const Text('自定义语音播报文案：', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: '如：还有五分钟，请放缓呼吸',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.volume_up, size: 18),
              label: const Text('试听此文案语音'),
              onPressed: () {
                final text = textController.text.trim();
                final speakText = text.isNotEmpty ? text : '这是一条测试播报';
                _chimeService.playChime(ChimeSoundType.gentleBell);
                _ttsService.speak(speakText);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _list.add(
                    Checkpoint.create(
                      offsetSeconds: offsetMinutes * 60,
                      triggerType: CheckpointTriggerType.remaining,
                      announcementText: text,
                    ),
                  );
                  // 按时间从大到小排序
                  _list.sort((a, b) => b.offsetSeconds.compareTo(a.offsetSeconds));
                });
                widget.onCheckpointsChanged(_list);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '播报节点设置 (${_list.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: '添加节点',
                onPressed: _showAddDialog,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '到设定时间节点时，应用会自动播放轻柔伴奏并朗读文案。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Divider(height: 24),
          Expanded(
            child: _list.isEmpty
                ? Center(
                    child: Text(
                      '暂无节点，点击右上角 + 添加',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: _list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final cp = _list[index];
                      final mins = cp.offsetSeconds ~/ 60;
                      final secs = cp.offsetSeconds % 60;
                      final timeLabel = secs == 0
                          ? '剩余 $mins 分钟'
                          : '剩余 $mins 分 $secs 秒';

                      return Card(
                        elevation: 0,
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          onTap: () {
                            CheckpointPopover.show(
                              context,
                              checkpoint: cp,
                              totalDurationSeconds: widget.totalDurationSeconds,
                              onUpdated: (updatedCp) {
                                setState(() {
                                  _list[index] = updatedCp;
                                  _list.sort((a, b) => b.offsetSeconds.compareTo(a.offsetSeconds));
                                });
                                widget.onCheckpointsChanged(_list);
                              },
                              onDeleted: () {
                                setState(() {
                                  _list.removeAt(index);
                                });
                                widget.onCheckpointsChanged(_list);
                              },
                            );
                          },
                          leading: IconButton.filledTonal(
                            icon: const Icon(Icons.volume_up, size: 18),
                            tooltip: '测试声音',
                            onPressed: () => _testAudio(cp),
                          ),
                          title: Text(
                            cp.announcementText,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              decoration: cp.isEnabled
                                  ? null
                                  : TextDecoration.lineThrough,
                            ),
                          ),
                          subtitle: Text(
                            timeLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: cp.isEnabled,
                                onChanged: (val) {
                                  setState(() {
                                    _list[index] = cp.copyWith(isEnabled: val);
                                  });
                                  widget.onCheckpointsChanged(_list);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _list.removeAt(index);
                                  });
                                  widget.onCheckpointsChanged(_list);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
