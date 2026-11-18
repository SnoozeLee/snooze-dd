import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snooze_dd/ui/theme/app_theme.dart';
import 'package:snooze_dd/ui/theme/theme_controller.dart';
import 'package:snooze_dd/ui/widgets/theme_setting_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeSettingDialog Widget Tests', () {
    late ThemeController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      controller = ThemeController();
      await controller.init();
    });

    Widget createTestApp() {
      return ThemeScope(
        controller: controller,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ThemeSettingDialog.show(context),
                child: const Text('打开主题设置'),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Renders all options and switches palette, mode, and texture', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 点击打开弹窗
      await tester.tap(find.text('打开主题设置'));
      await tester.pumpAndSettle();

      // 验证标题与选项均被渲染
      expect(find.text('个性化风格与质感'), findsOneWidget);
      expect(find.text('岩茶金石'), findsOneWidget);
      expect(find.text('松烟墨青'), findsOneWidget);
      expect(find.text('跟随系统'), findsOneWidget);
      expect(find.text('亮色'), findsOneWidget);
      expect(find.text('暗色'), findsOneWidget);
      expect(find.text('和纸砂石微粒'), findsOneWidget);
      expect(find.text('精密几何点阵'), findsOneWidget);
      expect(find.text('纯净无微粒'), findsOneWidget);

      // 切换为松烟墨青
      await tester.tap(find.text('松烟墨青'));
      await tester.pumpAndSettle();
      expect(controller.palette, AppPalette.pineSlate);

      // 切换为暗色模式
      await tester.tap(find.text('暗色'));
      await tester.pumpAndSettle();
      expect(controller.themeMode, ThemeMode.dark);

      // 切换为精密几何点阵
      await tester.tap(find.text('精密几何点阵'));
      await tester.pumpAndSettle();
      expect(controller.textureStyle, TextureStyle.dots);

      // 关闭弹窗
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('个性化风格与质感'), findsNothing);
    });
  });
}
