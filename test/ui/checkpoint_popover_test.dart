import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snooze_dd/models/checkpoint.dart';
import 'package:snooze_dd/ui/widgets/checkpoint_popover.dart';
import 'package:snooze_dd/ui/widgets/duration_picker_sheet.dart';

void main() {
  group('DurationPickerSheet Tests', () {
    testWidgets('Renders presets and allows selection', (tester) async {
      int? selectedMinutes;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  selectedMinutes = await DurationPickerSheet.show(
                    context,
                    initialMinutes: 25,
                  );
                },
                child: const Text('打开'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();

      expect(find.text('设置总时长'), findsOneWidget);
      expect(find.text('45 分钟'), findsOneWidget);

      // 点击 45 分钟预设
      await tester.tap(find.text('45 分钟'));
      await tester.pumpAndSettle();

      // 点击完成
      await tester.tap(find.text('完成'));
      await tester.pumpAndSettle();

      expect(selectedMinutes, 45);
    });
  });

  group('CheckpointPopover Tests', () {
    testWidgets('Renders checkpoint details and updates text', (tester) async {
      final cp = Checkpoint.create(
        offsetSeconds: 300,
        announcementText: '原播报内容',
      );

      Checkpoint? updatedCp;
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  CheckpointPopover.show(
                    context,
                    checkpoint: cp,
                    totalDurationSeconds: 1500,
                    onUpdated: (c) => updatedCp = c,
                    onDeleted: () => deleted = true,
                  );
                },
                child: const Text('打开Popover'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('打开Popover'));
      await tester.pumpAndSettle();

      expect(find.text('节点设置'), findsOneWidget);
      expect(find.text('原播报内容'), findsOneWidget);
      expect(find.text('测试声音 (试听播报)'), findsOneWidget);

      // 点击测试声音按钮
      await tester.tap(find.text('测试声音 (试听播报)'));
      await tester.pumpAndSettle();

      // 输入新内容
      await tester.enterText(find.byType(TextField), '新的节点文案');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      expect(updatedCp, isNotNull);
      expect(updatedCp!.announcementText, '新的节点文案');
      expect(deleted, isFalse);
    });

    testWidgets('Allows changing trigger time in CheckpointPopover', (tester) async {
      final cp = Checkpoint.create(
        offsetSeconds: 300, // 5 分钟
        triggerType: CheckpointTriggerType.remaining,
        announcementText: '原播报内容',
      );

      Checkpoint? updatedCp;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  CheckpointPopover.show(
                    context,
                    checkpoint: cp,
                    totalDurationSeconds: 1500, // 25 分钟
                    onUpdated: (c) => updatedCp = c,
                    onDeleted: () {},
                  );
                },
                child: const Text('打开Popover'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('打开Popover'));
      await tester.pumpAndSettle();

      expect(find.text('触发时间设置：'), findsOneWidget);
      expect(find.text('倒计剩余'), findsOneWidget);
      expect(find.text('5 分钟'), findsOneWidget);

      // 切换时间为 10 分钟
      await tester.tap(find.text('5 分钟'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('10 分钟').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      expect(updatedCp, isNotNull);
      expect(updatedCp!.offsetSeconds, 600); // 10 * 60
    });
  });
}
