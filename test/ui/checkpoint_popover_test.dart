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

  group('CheckpointPopover Tests (Unified Component)', () {
    testWidgets('Edit mode renders checkpoint details, allows editing and audio test', (tester) async {
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
      expect(find.text('测试声音 (试听伴音与播报)'), findsOneWidget);

      // 确保可见后点击测试声音按钮
      await tester.ensureVisible(find.text('测试声音 (试听伴音与播报)'));
      await tester.tap(find.text('测试声音 (试听伴音与播报)'));
      await tester.pumpAndSettle();

      // 输入新内容
      await tester.enterText(find.byType(TextField), '新的节点文案');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      expect(updatedCp, isNotNull);
      expect(updatedCp!.announcementText, '新的节点文案');
      expect(deleted, isFalse);
    });

    testWidgets('Edit mode allows switching trigger type via SegmentedButton', (tester) async {
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

      expect(find.text('触发基准类型：'), findsOneWidget);
      expect(find.text('倒计剩余'), findsOneWidget);
      expect(find.text('正计进行'), findsOneWidget);
      expect(find.text('剩余 5 分钟'), findsOneWidget);

      // 切换为正计进行
      await tester.tap(find.text('正计进行'));
      await tester.pumpAndSettle();

      expect(find.text('进行至 5 分钟'), findsOneWidget);

      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      expect(updatedCp, isNotNull);
      expect(updatedCp!.triggerType, CheckpointTriggerType.elapsed);
      expect(updatedCp!.offsetSeconds, 300);
    });

    testWidgets('Add mode renders unified dialog and creates new checkpoint', (tester) async {
      Checkpoint? createdCp;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  CheckpointPopover.show(
                    context,
                    checkpoint: null, // 添加模式
                    totalDurationSeconds: 1500,
                    onSaved: (c) => createdCp = c,
                  );
                },
                child: const Text('添加节点'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('添加节点'));
      await tester.pumpAndSettle();

      expect(find.text('添加播报节点'), findsOneWidget);
      expect(find.text('添加'), findsOneWidget);
      expect(find.text('倒计剩余'), findsOneWidget);
      expect(find.text('正计进行'), findsOneWidget);

      // 切换为正计进行
      await tester.tap(find.text('正计进行'));
      await tester.pumpAndSettle();

      // 输入文案
      await tester.enterText(find.byType(TextField), '专注进行到五分钟啦');

      // 点击添加按钮
      await tester.tap(find.text('添加'));
      await tester.pumpAndSettle();

      expect(createdCp, isNotNull);
      expect(createdCp!.triggerType, CheckpointTriggerType.elapsed);
      expect(createdCp!.announcementText, '专注进行到五分钟啦');
    });

    testWidgets('Auto update announcement text when time changes if not manually edited', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  CheckpointPopover.show(
                    context,
                    checkpoint: null,
                    totalDurationSeconds: 1500, // 25分钟
                    onSaved: (c) {},
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

      // 默认5分钟，文案为"还有五分钟"
      final textFieldFinder = find.byType(TextField);
      expect(tester.widget<TextField>(textFieldFinder).controller?.text, '还有五分钟');

      // 切换到3分钟下拉项
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('剩余 3 分钟').last);
      await tester.pumpAndSettle();

      // 文案自动更新为"还有三分钟"
      expect(tester.widget<TextField>(textFieldFinder).controller?.text, '还有三分钟');

      // 切换到"正计进行"
      await tester.tap(find.text('正计进行'));
      await tester.pumpAndSettle();

      // 文案自动更新为"已经进行三分钟"
      expect(tester.widget<TextField>(textFieldFinder).controller?.text, '已经进行三分钟');

      // 用户手动输入自定义文案
      await tester.enterText(textFieldFinder, '喝水时间到');
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(textFieldFinder).controller?.text, '喝水时间到');

      // 再次切换到2分钟下拉项
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('进行至 2 分钟').last);
      await tester.pumpAndSettle();

      // 文案保持用户自定义内容，不被覆盖
      expect(tester.widget<TextField>(textFieldFinder).controller?.text, '喝水时间到');
    });
  });
}
