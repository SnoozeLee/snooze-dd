import 'package:uuid/uuid.dart';
import 'checkpoint.dart';

enum TimerMode {
  countdown,
  stopwatch,
}

enum TimerStatus {
  idle,
  running,
  paused,
  completed,
}

/// 应用内 5 级离散独立音量等级
enum VolumeLevel {
  level1(1, 0.20, '1级 (20%)', '极轻柔，适合耳机或静心冥想'),
  level2(2, 0.40, '2级 (40%)', '柔和，适合安静书房或夜间小憩'),
  level3(3, 0.60, '3级 (60%)', '适中，标准平衡伴随音量'),
  level4(4, 0.80, '4级 (80%)', '清晰，日常专注默认推荐'),
  level5(5, 1.00, '5级 (100%)', '饱满响亮，适合外放或有背景音环境');

  final int level;
  final double scalar;
  final String label;
  final String description;

  const VolumeLevel(this.level, this.scalar, this.label, this.description);

  static VolumeLevel fromScalar(double scalar) {
    if (scalar <= 0.30) return VolumeLevel.level1;
    if (scalar <= 0.50) return VolumeLevel.level2;
    if (scalar <= 0.70) return VolumeLevel.level3;
    if (scalar <= 0.90) return VolumeLevel.level4;
    return VolumeLevel.level5;
  }
}

/// 计时器会话与参数配置模型
class TimerSession {
  final String id;
  final String name;
  final TimerMode mode;
  final int totalDurationSeconds;
  final List<Checkpoint> checkpoints;
  final bool keepScreenAwake;
  final double volume;

  const TimerSession({
    required this.id,
    required this.name,
    this.mode = TimerMode.countdown,
    required this.totalDurationSeconds,
    this.checkpoints = const [],
    this.keepScreenAwake = true,
    this.volume = 0.8,
  });

  /// 默认 25 分钟专注预设配置
  factory TimerSession.defaultPomodoro() {
    return TimerSession(
      id: const Uuid().v4(),
      name: '专注番茄钟',
      mode: TimerMode.countdown,
      totalDurationSeconds: 25 * 60,
      checkpoints: [
        Checkpoint.create(
          offsetSeconds: 10 * 60,
          triggerType: CheckpointTriggerType.remaining,
          announcementText: '还有十分钟，请保持专注',
        ),
        Checkpoint.create(
          offsetSeconds: 5 * 60,
          triggerType: CheckpointTriggerType.remaining,
          announcementText: '最后五分钟，准备收尾',
        ),
      ],
      keepScreenAwake: true,
      volume: 0.8,
    );
  }

  TimerSession copyWith({
    String? id,
    String? name,
    TimerMode? mode,
    int? totalDurationSeconds,
    List<Checkpoint>? checkpoints,
    bool? keepScreenAwake,
    double? volume,
  }) {
    return TimerSession(
      id: id ?? this.id,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      checkpoints: checkpoints ?? this.checkpoints,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      volume: volume ?? this.volume,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mode': mode.name,
      'totalDurationSeconds': totalDurationSeconds,
      'checkpoints': checkpoints.map((c) => c.toJson()).toList(),
      'keepScreenAwake': keepScreenAwake,
      'volume': volume,
    };
  }

  factory TimerSession.fromJson(Map<String, dynamic> json) {
    return TimerSession(
      id: json['id'] as String,
      name: json['name'] as String,
      mode: TimerMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => TimerMode.countdown,
      ),
      totalDurationSeconds: json['totalDurationSeconds'] as int,
      checkpoints: (json['checkpoints'] as List<dynamic>?)
              ?.map((item) => Checkpoint.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      keepScreenAwake: json['keepScreenAwake'] as bool? ?? true,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.8,
    );
  }
}
