import 'package:flutter/material.dart';
import '../../core/timer_engine.dart';
import '../../models/checkpoint.dart';
import '../../models/timer_session.dart';
import '../../services/audio_chime_service.dart';
import '../../services/storage_service.dart';
import '../../services/tts_service.dart';
import '../widgets/checkpoint_list_sheet.dart';
import '../widgets/checkpoint_popover.dart';
import '../widgets/duration_picker_sheet.dart';
import '../widgets/timer_dial.dart';

/// SnoozeDD 核心计时与多节点播报主页面
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with WidgetsBindingObserver {
  late TimerSession _session;
  late TimerEngine _engine;

  final TtsService _ttsService = TtsService();
  final AudioChimeService _chimeService = AudioChimeService();

  int _remainingSeconds = 0;
  double _progress = 0.0;
  TimerStatus _status = TimerStatus.idle;
  String _latestAnnouncement = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _session = TimerSession.defaultPomodoro();
    _remainingSeconds = _session.totalDurationSeconds;

    _engine = TimerEngine(
      session: _session,
      onTick: (remaining, _) {
        setState(() {
          _remainingSeconds = remaining;
          _progress = _engine.progress;
        });
      },
      onStatusChanged: (status) {
        setState(() {
          _status = status;
        });
      },
      onCheckpointTriggered: _handleCheckpointTriggered,
      onCompleted: _handleCompleted,
    );

    _initServicesAndLoadData();
  }

  Future<void> _initServicesAndLoadData() async {
    await _ttsService.init();
    await _chimeService.init();

    final savedSession = await StorageService.loadLatestSession();
    if (mounted) {
      setState(() {
        _session = savedSession;
        _remainingSeconds = _session.totalDurationSeconds;
        _engine.updateSession(_session);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 当从后台切换回前台时，主动校准高精度时间
    if (state == AppLifecycleState.resumed) {
      _engine.calibrateWithCurrentTime();
    }
  }

  void _handleCheckpointTriggered(Checkpoint checkpoint) {
    setState(() {
      _latestAnnouncement = checkpoint.announcementText;
    });

    // 1. 播放轻柔提示音
    _chimeService.playChime(checkpoint.chimeSound, volume: _session.volume);

    // 2. 离线 TTS 朗读自定义文本 (若有伴随音，略微错开 700ms 避免声音混杂)
    final delay = checkpoint.chimeSound != ChimeSoundType.none
        ? const Duration(milliseconds: 700)
        : Duration.zero;

    Future.delayed(delay, () {
      if (mounted) {
        _ttsService.speak(checkpoint.announcementText, volume: _session.volume);
      }
    });

    // 3. 屏幕底部弹出轻量弱提醒条
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              const Icon(Icons.volume_up, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text('节点提示：${checkpoint.announcementText}'),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _handleCompleted() {
    setState(() {
      _latestAnnouncement = '本次专注已完成';
    });
    _ttsService.speak('本次专注已完成，请好好休息一下吧', volume: _session.volume);
  }

  void _changeDuration(int minutes) {
    if (_status == TimerStatus.running) return;

    final newTotalSeconds = minutes * 60;
    if (_session.totalDurationSeconds == newTotalSeconds) return;

    // 节点越界保护：超出新时长的节点自动停用
    int disabledCount = 0;
    final updatedCheckpoints = _session.checkpoints.map((cp) {
      bool isOutOfRange = false;
      if (cp.triggerType == CheckpointTriggerType.remaining &&
          cp.offsetSeconds >= newTotalSeconds) {
        isOutOfRange = true;
      } else if (cp.triggerType == CheckpointTriggerType.elapsed &&
          cp.offsetSeconds > newTotalSeconds) {
        isOutOfRange = true;
      }

      if (isOutOfRange && cp.isEnabled) {
        disabledCount++;
        return cp.copyWith(isEnabled: false);
      }
      return cp;
    }).toList();

    final updated = _session.copyWith(
      totalDurationSeconds: newTotalSeconds,
      checkpoints: updatedCheckpoints,
    );

    setState(() {
      _session = updated;
      _remainingSeconds = updated.totalDurationSeconds;
      _engine.updateSession(updated);
    });
    StorageService.saveSession(updated);

    if (disabledCount > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('有 $disabledCount 个节点超出新总时长范围，已自动停用'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openDurationPicker() async {
    if (_status == TimerStatus.running) return;

    final currentMinutes = (_session.totalDurationSeconds / 60).round();
    final selected = await DurationPickerSheet.show(
      context,
      initialMinutes: currentMinutes,
    );

    if (selected != null && selected > 0) {
      _changeDuration(selected);
    }
  }

  void _openCheckpointPopover(Checkpoint checkpoint) {
    CheckpointPopover.show(
      context,
      checkpoint: checkpoint,
      totalDurationSeconds: _session.totalDurationSeconds,
      onUpdated: (updatedCp) {
        final newCheckpoints = _session.checkpoints.map((cp) {
          return cp.id == updatedCp.id ? updatedCp : cp;
        }).toList();

        final updated = _session.copyWith(checkpoints: newCheckpoints);
        setState(() {
          _session = updated;
          _engine.updateSession(updated);
        });
        StorageService.saveSession(updated);
      },
      onDeleted: () {
        final newCheckpoints = _session.checkpoints
            .where((cp) => cp.id != checkpoint.id)
            .toList();

        final updated = _session.copyWith(checkpoints: newCheckpoints);
        setState(() {
          _session = updated;
          _engine.updateSession(updated);
        });
        StorageService.saveSession(updated);
      },
    );
  }

  void _openCheckpointsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => CheckpointListSheet(
        checkpoints: _session.checkpoints,
        totalDurationSeconds: _session.totalDurationSeconds,
        onCheckpointsChanged: (newCheckpoints) {
          final updated = _session.copyWith(checkpoints: newCheckpoints);
          setState(() {
            _session = updated;
            _engine.updateSession(updated);
          });
          StorageService.saveSession(updated);
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _engine.dispose();
    _chimeService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentMinutes = (_session.totalDurationSeconds / 60).round();
    const standardPresets = [15, 25, 45, 60];
    final isCustomDuration = !standardPresets.contains(currentMinutes);

    return Scaffold(
      appBar: AppBar(
        title: Text(_session.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: '配置提醒节点',
            onPressed: _openCheckpointsModal,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 时长快速选择预设与自定义滚轮入口
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...standardPresets.map((mins) {
                      final isSelected = currentMinutes == mins;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text('$mins 分钟'),
                          onSelected: _status == TimerStatus.running
                              ? null
                              : (_) => _changeDuration(mins),
                        ),
                      );
                    }),
                    if (isCustomDuration)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: true,
                          label: Text('$currentMinutes 分钟'),
                          onSelected: _status == TimerStatus.running
                              ? null
                              : (_) => _openDurationPicker(),
                        ),
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.tune, size: 16),
                      label: const Text('自定义...'),
                      onPressed: _status == TimerStatus.running
                          ? null
                          : _openDurationPicker,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // 环形主表盘 (支持圆弧节点可视化与点击)
            TimerDial(
              remainingSeconds: _remainingSeconds,
              totalSeconds: _session.totalDurationSeconds,
              progress: _progress,
              isRunning: _status == TimerStatus.running,
              statusText: _latestAnnouncement,
              checkpoints: _session.checkpoints,
              triggeredCheckpointIds: _engine.triggeredCheckpointIds,
              onCheckpointTap: _openCheckpointPopover,
              onDialCenterTap:
                  _status == TimerStatus.running ? null : _openDurationPicker,
            ),
            const SizedBox(height: 24),
            // 节点摘要展示
            GestureDetector(
              onTap: _openCheckpointsModal,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timeline,
                        size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '已启用 ${_session.checkpoints.where((c) => c.isEnabled).length} 个播报节点',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // 底部操作控制面板
            Padding(
              padding: const EdgeInsets.only(bottom: 32, left: 32, right: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 重置按钮
                  IconButton.filledTonal(
                    iconSize: 28,
                    icon: const Icon(Icons.refresh),
                    tooltip: '重置',
                    onPressed: _status == TimerStatus.idle
                        ? null
                        : () {
                            _engine.reset();
                            _ttsService.stop();
                            setState(() {
                              _latestAnnouncement = '';
                            });
                          },
                  ),
                  // 主操作按钮 (开始/暂停)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    icon: Icon(
                      _status == TimerStatus.running
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    label: Text(
                      _status == TimerStatus.running
                          ? '暂停'
                          : (_status == TimerStatus.paused ? '继续' : '开始'),
                      style: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      if (_status == TimerStatus.running) {
                        _engine.pause();
                      } else {
                        _engine.start();
                      }
                    },
                  ),
                  // 节点配置快捷入口
                  IconButton.filledTonal(
                    iconSize: 28,
                    icon: const Icon(Icons.tune),
                    tooltip: '节点详情',
                    onPressed: _openCheckpointsModal,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
