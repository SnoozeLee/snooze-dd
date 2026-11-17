import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snooze_dd/models/timer_session.dart';
import 'package:snooze_dd/ui/widgets/volume_setting_dialog.dart';

void main() {
  group('VolumeLevel Mapping Unit Tests', () {
    test('fromScalar correctly maps to 5 discrete volume levels', () {
      expect(VolumeLevel.fromScalar(0.20), VolumeLevel.level1);
      expect(VolumeLevel.fromScalar(0.40), VolumeLevel.level2);
      expect(VolumeLevel.fromScalar(0.60), VolumeLevel.level3);
      expect(VolumeLevel.fromScalar(0.80), VolumeLevel.level4);
      expect(VolumeLevel.fromScalar(1.00), VolumeLevel.level5);

      // 边缘测试
      expect(VolumeLevel.fromScalar(0.0), VolumeLevel.level1);
      expect(VolumeLevel.fromScalar(0.25), VolumeLevel.level1);
      expect(VolumeLevel.fromScalar(0.75), VolumeLevel.level4);
      expect(VolumeLevel.fromScalar(1.2), VolumeLevel.level5);
    });

    test('VolumeLevel properties are consistent', () {
      expect(VolumeLevel.level1.level, 1);
      expect(VolumeLevel.level1.scalar, 0.20);
      expect(VolumeLevel.level5.level, 5);
      expect(VolumeLevel.level5.scalar, 1.00);
    });
  });

  group('VolumeSettingDialog Widget Tests', () {
    testWidgets('Renders 5 volume levels and allows level selection', (tester) async {
      double? changedVolume;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  VolumeSettingDialog.show(
                    context,
                    currentVolume: 0.8,
                    onVolumeChanged: (val) => changedVolume = val,
                  );
                },
                child: const Text('打开音量设置'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('打开音量设置'));
      await tester.pumpAndSettle();

      expect(find.text('应用内音量设置'), findsOneWidget);
      expect(find.text('第 4 / 5 级'), findsOneWidget);
      expect(find.text('4级 (80%)'), findsOneWidget);
      expect(find.text('试听第 4 级音量效果'), findsOneWidget);

      // 点击试听按钮
      await tester.tap(find.text('试听第 4 级音量效果'));
      await tester.pumpAndSettle();

      // 点击确认保存
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      expect(changedVolume, 0.80);
    });
  });
}
