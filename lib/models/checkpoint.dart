import 'package:uuid/uuid.dart';

/// 播报触发基准类型
enum CheckpointTriggerType {
  /// 剩余时间到达设定阈值（例如：剩余 600 秒时触发）
  remaining,

  /// 已经流逝的时间到达设定阈值（例如：正向或倒计时进行到 1800 秒时触发）
  elapsed,
}

/// 伴随提示音类型
enum ChimeSoundType {
  none,
  gentleBell,
  waterDrop,
  singingBowl,
}

/// 播报时间节点实体模型
class Checkpoint {
  final String id;
  final int offsetSeconds;
  final CheckpointTriggerType triggerType;
  final String announcementText;
  final ChimeSoundType chimeSound;
  final bool isEnabled;

  const Checkpoint({
    required this.id,
    required this.offsetSeconds,
    this.triggerType = CheckpointTriggerType.remaining,
    required this.announcementText,
    this.chimeSound = ChimeSoundType.gentleBell,
    this.isEnabled = true,
  });

  /// 创建一个具备默认 UUID 的新节点
  factory Checkpoint.create({
    required int offsetSeconds,
    CheckpointTriggerType triggerType = CheckpointTriggerType.remaining,
    required String announcementText,
    ChimeSoundType chimeSound = ChimeSoundType.gentleBell,
    bool isEnabled = true,
  }) {
    return Checkpoint(
      id: const Uuid().v4(),
      offsetSeconds: offsetSeconds,
      triggerType: triggerType,
      announcementText: announcementText,
      chimeSound: chimeSound,
      isEnabled: isEnabled,
    );
  }

  /// 计算在给定总时长下的实际触发时间点（从开始流逝的秒数，用于执行时序排序）
  int getTriggerElapsedSeconds(int totalDurationSeconds) {
    if (triggerType == CheckpointTriggerType.elapsed) {
      return offsetSeconds;
    } else {
      return (totalDurationSeconds - offsetSeconds).clamp(0, totalDurationSeconds);
    }
  }

  /// 格式化时间触发展示标签（如：'已进行至 5 分钟' 或 '剩余 10 分钟'）
  String get formattedTriggerLabel {
    final mins = offsetSeconds ~/ 60;
    final secs = offsetSeconds % 60;
    final prefix = triggerType == CheckpointTriggerType.remaining ? '剩余' : '已进行至';
    if (secs == 0) {
      return '$prefix $mins 分钟';
    } else {
      return '$prefix $mins 分 $secs 秒';
    }
  }

  Checkpoint copyWith({
    String? id,
    int? offsetSeconds,
    CheckpointTriggerType? triggerType,
    String? announcementText,
    ChimeSoundType? chimeSound,
    bool? isEnabled,
  }) {
    return Checkpoint(
      id: id ?? this.id,
      offsetSeconds: offsetSeconds ?? this.offsetSeconds,
      triggerType: triggerType ?? this.triggerType,
      announcementText: announcementText ?? this.announcementText,
      chimeSound: chimeSound ?? this.chimeSound,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'offsetSeconds': offsetSeconds,
      'triggerType': triggerType.name,
      'announcementText': announcementText,
      'chimeSound': chimeSound.name,
      'isEnabled': isEnabled,
    };
  }

  factory Checkpoint.fromJson(Map<String, dynamic> json) {
    return Checkpoint(
      id: json['id'] as String,
      offsetSeconds: json['offsetSeconds'] as int,
      triggerType: CheckpointTriggerType.values.firstWhere(
        (e) => e.name == json['triggerType'],
        orElse: () => CheckpointTriggerType.remaining,
      ),
      announcementText: json['announcementText'] as String,
      chimeSound: ChimeSoundType.values.firstWhere(
        (e) => e.name == json['chimeSound'],
        orElse: () => ChimeSoundType.gentleBell,
      ),
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }
}
