import 'package:flutter_test/flutter_test.dart';
import 'package:snooze_dd/core/timer_engine.dart';
import 'package:snooze_dd/models/checkpoint.dart';
import 'package:snooze_dd/models/timer_session.dart';

void main() {
  group('Checkpoint & TimerSession Models', () {
    test('Checkpoint serialization and copyWith', () {
      final cp = Checkpoint.create(
        offsetSeconds: 300,
        triggerType: CheckpointTriggerType.remaining,
        announcementText: '还剩5分钟',
        chimeSound: ChimeSoundType.gentleBell,
      );

      final json = cp.toJson();
      final restored = Checkpoint.fromJson(json);

      expect(restored.id, cp.id);
      expect(restored.offsetSeconds, 300);
      expect(restored.triggerType, CheckpointTriggerType.remaining);
      expect(restored.announcementText, '还剩5分钟');
      expect(restored.chimeSound, ChimeSoundType.gentleBell);
      expect(restored.isEnabled, true);

      final modified = cp.copyWith(isEnabled: false, offsetSeconds: 120);
      expect(modified.isEnabled, false);
      expect(modified.offsetSeconds, 120);
    });

    test('Checkpoint formattedTriggerLabel and getTriggerElapsedSeconds', () {
      const totalDuration = 1500; // 25 分钟

      // 1. 剩余时间节点 (20分钟处触发)
      final cpRemaining = Checkpoint.create(
        offsetSeconds: 300, // 剩余 5 分钟
        triggerType: CheckpointTriggerType.remaining,
        announcementText: '剩余5分钟',
      );
      expect(cpRemaining.formattedTriggerLabel, '剩余 5 分钟');
      expect(cpRemaining.getTriggerElapsedSeconds(totalDuration), 1200); // 1500 - 300 = 1200秒 (第20分钟)

      // 2. 正向已进行节点 (5分钟处触发)
      final cpElapsed = Checkpoint.create(
        offsetSeconds: 300, // 进行到 5 分钟
        triggerType: CheckpointTriggerType.elapsed,
        announcementText: '已进行5分钟',
      );
      expect(cpElapsed.formattedTriggerLabel, '已进行至 5 分钟');
      expect(cpElapsed.getTriggerElapsedSeconds(totalDuration), 300); // 第5分钟触发

      // 3. 含秒数情况
      final cpSecs = Checkpoint.create(
        offsetSeconds: 150, // 2分30秒
        triggerType: CheckpointTriggerType.elapsed,
        announcementText: '测试',
      );
      expect(cpSecs.formattedTriggerLabel, '已进行至 2 分 30 秒');
    });

    test('TimerSession defaultPomodoro and serialization', () {
      final session = TimerSession.defaultPomodoro();

      expect(session.name, '专注番茄钟');
      expect(session.totalDurationSeconds, 1500);
      expect(session.checkpoints.length, 2);

      final json = session.toJson();
      final restored = TimerSession.fromJson(json);

      expect(restored.id, session.id);
      expect(restored.totalDurationSeconds, 1500);
      expect(restored.checkpoints.length, 2);
    });
  });

  group('TimerEngine Core Logic', () {
    late TimerSession testSession;

    setUp(() {
      testSession = TimerSession(
        id: 'test-session',
        name: '测试计时',
        totalDurationSeconds: 10,
        checkpoints: [
          Checkpoint.create(
            offsetSeconds: 5,
            triggerType: CheckpointTriggerType.remaining,
            announcementText: '剩余5秒',
          ),
          Checkpoint.create(
            offsetSeconds: 3,
            triggerType: CheckpointTriggerType.elapsed,
            announcementText: '已过去3秒',
          ),
        ],
      );
    });

    test('Initial state reflects session settings', () {
      final engine = TimerEngine(session: testSession);

      expect(engine.status, TimerStatus.idle);
      expect(engine.isIdle, true);
      expect(engine.remainingSeconds, 10);
      expect(engine.elapsedSeconds, 0);
      expect(engine.progress, 0.0);
    });

    test('Start and pause changes state properly', () {
      final engine = TimerEngine(session: testSession);
      TimerStatus? latestStatus;
      engine.onStatusChanged = (status) => latestStatus = status;

      engine.start();
      expect(engine.status, TimerStatus.running);
      expect(engine.isRunning, true);
      expect(latestStatus, TimerStatus.running);

      engine.pause();
      expect(engine.status, TimerStatus.paused);
      expect(engine.isPaused, true);
      expect(latestStatus, TimerStatus.paused);

      engine.reset();
      expect(engine.status, TimerStatus.idle);
      expect(engine.isIdle, true);
      expect(latestStatus, TimerStatus.idle);
      expect(engine.remainingSeconds, 10);
      expect(engine.elapsedSeconds, 0);
    });

    test('Checkpoints trigger without duplicates', () {
      final engine = TimerEngine(session: testSession);
      final List<String> triggeredTexts = [];

      engine.onCheckpointTriggered = (cp) {
        triggeredTexts.add(cp.announcementText);
      };

      engine.start();

      // 手动触发一次校准以验证
      engine.calibrateWithCurrentTime();

      expect(engine.triggeredCheckpointIds.length, 0);
      engine.dispose();
    });
  });
}
