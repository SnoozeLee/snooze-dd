import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snooze_dd/services/storage_service.dart';
import 'package:snooze_dd/ui/theme/app_theme.dart';
import 'package:snooze_dd/ui/theme/theme_controller.dart';
import 'package:snooze_dd/ui/widgets/texture_background.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeController Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Loads defaults and updates palette', () async {
      final controller = ThemeController();
      await controller.init();

      expect(controller.palette, AppPalette.warmUmber);
      expect(controller.themeMode, ThemeMode.system);
      expect(controller.textureStyle, TextureStyle.grain);

      int notifyCount = 0;
      controller.addListener(() {
        notifyCount++;
      });

      await controller.setPalette(AppPalette.pineSlate);
      expect(controller.palette, AppPalette.pineSlate);
      expect(notifyCount, 1);
      expect(await StorageService.loadPalette(), AppPalette.pineSlate);

      await controller.setThemeMode(ThemeMode.dark);
      expect(controller.themeMode, ThemeMode.dark);
      expect(notifyCount, 2);
      expect(await StorageService.loadThemeMode(), ThemeMode.dark);

      await controller.setTextureStyle(TextureStyle.dots);
      expect(controller.textureStyle, TextureStyle.dots);
      expect(notifyCount, 3);
      expect(await StorageService.loadTextureStyle(), TextureStyle.dots);
    });

    test('Provides correct lightTheme and darkTheme based on current palette', () async {
      final controller = ThemeController();
      await controller.init();

      expect(controller.lightTheme.colorScheme.primary, AppTheme.warmLightPrimary);
      expect(controller.darkTheme.colorScheme.primary, AppTheme.warmDarkPrimary);

      await controller.setPalette(AppPalette.pineSlate);
      expect(controller.lightTheme.colorScheme.primary, AppTheme.pineLightPrimary);
      expect(controller.darkTheme.colorScheme.primary, AppTheme.pineDarkPrimary);
    });
  });

  group('TextureBackground Widget Tests', () {
    testWidgets('Renders child without errors across all texture styles', (tester) async {
      for (final style in TextureStyle.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.buildTheme(
              palette: AppPalette.warmUmber,
              brightness: Brightness.light,
            ),
            home: Scaffold(
              body: TextureBackground(
                style: style,
                child: const Text('Texture Test Content'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Texture Test Content'), findsOneWidget);
      }
    });
  });
}
