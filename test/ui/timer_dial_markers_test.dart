import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snooze_dd/models/checkpoint.dart';
import 'package:snooze_dd/ui/widgets/timer_dial.dart';

void main() {
  group('DialMarkerHelper Calculations', () {
    test('calculateMarkers returns empty for empty input or 0 totalSeconds', () {
      expect(
        DialMarkerHelper.calculateMarkers(
          checkpoints: [],
          totalDurationSeconds: 1500,
        ),
        isEmpty,
      );

      final cp = Checkpoint.create(
        offsetSeconds: 300,
        announcementText: '测试',
      );
      expect(
        DialMarkerHelper.calculateMarkers(
          checkpoints: [cp],
          totalDurationSeconds: 0,
        ),
        isEmpty,
      );
    });

    test('calculateMarkers correctly calculates ratio and angle for remaining type', () {
      const totalSeconds = 3600; // 60 分钟
      final cp15 = Checkpoint.create(
        offsetSeconds: 900, // 剩余 15 分钟
        triggerType: CheckpointTriggerType.remaining,
        announcementText: '15分钟',
      );
      final cp30 = Checkpoint.create(
        offsetSeconds: 1800, // 剩余 30 分钟
        triggerType: CheckpointTriggerType.remaining,
        announcementText: '30分钟',
      );

      final markers = DialMarkerHelper.calculateMarkers(
        checkpoints: [cp15, cp30],
        totalDurationSeconds: totalSeconds,
      );

      expect(markers.length, 2);

      // 验证 cp15 (25% 弧长)
      final m15 = markers.firstWhere((m) => m.checkpoint.id == cp15.id);
      expect(m15.ratio, closeTo(0.25, 0.001));
      // -pi/2 + 0.25 * 2 * pi = 0.0
      expect(m15.angle, closeTo(0.0, 0.001));
      expect(m15.label, '⏳ 15m');
      expect(m15.showLabel, isTrue);

      // 验证 cp30 (50% 弧长)
      final m30 = markers.firstWhere((m) => m.checkpoint.id == cp30.id);
      expect(m30.ratio, closeTo(0.50, 0.001));
      // -pi/2 + 0.50 * 2 * pi = pi/2
      expect(m30.angle, closeTo(pi / 2, 0.001));
      expect(m30.label, '⏳ 30m');
      expect(m30.showLabel, isTrue);
    });

    test('calculateMarkers correctly calculates ratio for elapsed type', () {
      const totalSeconds = 3600; // 60 分钟
      final cpElapsed10 = Checkpoint.create(
        offsetSeconds: 600, // 已进行 10 分钟 (剩余 50 分钟)
        triggerType: CheckpointTriggerType.elapsed,
        announcementText: '进行10分钟',
      );

      final markers = DialMarkerHelper.calculateMarkers(
        checkpoints: [cpElapsed10],
        totalDurationSeconds: totalSeconds,
      );

      expect(markers.length, 1);
      // 剩余比例 (3600 - 600) / 3600 = 5/6 = ~0.8333
      expect(markers.first.ratio, closeTo(5 / 6, 0.001));
      expect(markers.first.label, '▶ 10m');
    });

    test('calculateMarkers suppresses overlapping labels when angle difference < 15 degrees', () {
      const totalSeconds = 3600; // 60 分钟 = 360 度，每分钟 6 度
      // 两个相隔 1 分钟的节点 (6度差 < 15度阈值)
      final cp1 = Checkpoint.create(
        offsetSeconds: 600, // 10分钟
        announcementText: '10分',
      );
      final cp2 = Checkpoint.create(
        offsetSeconds: 660, // 11分钟
        announcementText: '11分',
      );

      final markers = DialMarkerHelper.calculateMarkers(
        checkpoints: [cp1, cp2],
        totalDurationSeconds: totalSeconds,
      );

      expect(markers.length, 2);
      expect(markers[0].showLabel, isFalse);
      expect(markers[1].showLabel, isFalse);
    });
  });

  group('TimerDial Widget Interaction', () {
    testWidgets('Tapping center triggers onDialCenterTap', (tester) async {
      bool centerTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimerDial(
              remainingSeconds: 1500,
              totalSeconds: 1500,
              progress: 0.0,
              isRunning: false,
              onDialCenterTap: () => centerTapped = true,
            ),
          ),
        ),
      );

      // 点击表盘中心
      await tester.tap(find.byType(TimerDial));
      await tester.pumpAndSettle();

      expect(centerTapped, isTrue);
    });

    testWidgets('Tapping checkpoint marker invokes onCheckpointTap', (tester) async {
      Checkpoint? tapped;
      // 剩余 15 分钟节点，在 60 分钟总长中位于 25% (角度为 0，即正右方 3 点钟方向)
      // 表盘中心为 (140, 140)，半径 105，因此标记点位于 (140 + 105, 140) = (245, 140)
      final cp = Checkpoint.create(
        offsetSeconds: 900,
        triggerType: CheckpointTriggerType.remaining,
        announcementText: '15分钟提示',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TimerDial(
                remainingSeconds: 3600,
                totalSeconds: 3600,
                progress: 0.0,
                isRunning: false,
                checkpoints: [cp],
                onCheckpointTap: (c) => tapped = c,
              ),
            ),
          ),
        ),
      );

      final dialFinder = find.byType(TimerDial);
      final dialCenter = tester.getCenter(dialFinder);

      // 目标标记点在表盘中心正右方 105px 处
      final markerTarget = dialCenter + const Offset(105, 0);

      await tester.tapAt(markerTarget);
      await tester.pumpAndSettle();

      expect(tapped, isNotNull);
      expect(tapped!.id, cp.id);
    });
  });
}
