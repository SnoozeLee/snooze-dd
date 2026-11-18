import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snooze_dd/models/checkpoint.dart';
import 'package:snooze_dd/ui/widgets/checkpoint_list_sheet.dart';

void main() {
  group('CheckpointListSheet Timeline Sorting & Label Tests', () {
    testWidgets('Displays elapsed vs remaining labels correctly and sorts in runtime timeline order', (tester) async {
      const totalDuration = 1500; // 25 分钟

      // 准备三个乱序节点：
      // cpRemaining5: 剩余 5 分钟 -> 实际在第 20 分钟（1200秒）触发
      // cpElapsed5: 已进行至 5 分钟 -> 实际在第 5 分钟（300秒）触发
      // cpRemaining10: 剩余 10 分钟 -> 实际在第 15 分钟（900秒）触发
      final cpRemaining5 = Checkpoint.create(
        offsetSeconds: 300,
        triggerType: CheckpointTriggerType.remaining,
        announcementText: '节点：剩5分',
      );
      final cpElapsed5 = Checkpoint.create(
        offsetSeconds: 300,
        triggerType: CheckpointTriggerType.elapsed,
        announcementText: '节点：过5分',
      );
      final cpRemaining10 = Checkpoint.create(
        offsetSeconds: 600,
        triggerType: CheckpointTriggerType.remaining,
        announcementText: '节点：剩10分',
      );

      final checkpoints = [cpRemaining5, cpElapsed5, cpRemaining10];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CheckpointListSheet(
              checkpoints: checkpoints,
              totalDurationSeconds: totalDuration,
              onCheckpointsChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. 验证文案准确性：已进行至 vs 剩余
      expect(find.text('已进行至 5 分钟'), findsOneWidget);
      expect(find.text('剩余 10 分钟'), findsOneWidget);
      expect(find.text('剩余 5 分钟'), findsOneWidget);

      // 2. 验证时序升序排列：
      // 第1个应该在第5分钟 (过5分)，第2个在第15分钟 (剩10分)，第3个在第20分钟 (剩5分)
      final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(tiles.length, 3);

      final title1 = (tiles[0].title as Text).data;
      final subtitle1 = (tiles[0].subtitle as Text).data;
      expect(title1, '节点：过5分');
      expect(subtitle1, '已进行至 5 分钟');

      final title2 = (tiles[1].title as Text).data;
      final subtitle2 = (tiles[1].subtitle as Text).data;
      expect(title2, '节点：剩10分');
      expect(subtitle2, '剩余 10 分钟');

      final title3 = (tiles[2].title as Text).data;
      final subtitle3 = (tiles[2].subtitle as Text).data;
      expect(title3, '节点：剩5分');
      expect(subtitle3, '剩余 5 分钟');
    });
  });
}
