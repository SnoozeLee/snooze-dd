import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snooze_dd/services/storage_service.dart';
import 'package:snooze_dd/ui/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppTheme Specifications & Token Tests', () {
    test('Builds Warm Umber Light theme with high-contrast tokens', () {
      final theme = AppTheme.buildTheme(
        palette: AppPalette.warmUmber,
        brightness: Brightness.light,
      );

      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppTheme.warmLightScaffold);
      expect(theme.colorScheme.onSurface, AppTheme.warmLightOnSurface);
      expect(theme.colorScheme.primary, AppTheme.warmLightPrimary);

      final dialExt = theme.extension<DialThemeExtension>();
      expect(dialExt, isNotNull);
      expect(dialExt!.trackColor, AppTheme.warmLightTrack);
      expect(dialExt.primaryArcColor, AppTheme.warmLightPrimary);
      expect(dialExt.accentMarkerColor, AppTheme.warmLightAccent);
    });

    test('Builds Warm Umber Dark theme with high-contrast tokens', () {
      final theme = AppTheme.buildTheme(
        palette: AppPalette.warmUmber,
        brightness: Brightness.dark,
      );

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppTheme.warmDarkScaffold);
      expect(theme.colorScheme.onSurface, AppTheme.warmDarkOnSurface);
      expect(theme.colorScheme.primary, AppTheme.warmDarkPrimary);

      final dialExt = theme.extension<DialThemeExtension>();
      expect(dialExt, isNotNull);
      expect(dialExt!.trackColor, AppTheme.warmDarkTrack);
      expect(dialExt.primaryArcColor, AppTheme.warmDarkPrimary);
      expect(dialExt.accentMarkerColor, AppTheme.warmDarkAccent);
    });

    test('Builds Pine Slate Light theme with high-contrast tokens', () {
      final theme = AppTheme.buildTheme(
        palette: AppPalette.pineSlate,
        brightness: Brightness.light,
      );

      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppTheme.pineLightScaffold);
      expect(theme.colorScheme.onSurface, AppTheme.pineLightOnSurface);
      expect(theme.colorScheme.primary, AppTheme.pineLightPrimary);

      final dialExt = theme.extension<DialThemeExtension>();
      expect(dialExt, isNotNull);
      expect(dialExt!.trackColor, AppTheme.pineLightTrack);
      expect(dialExt.primaryArcColor, AppTheme.pineLightPrimary);
      expect(dialExt.accentMarkerColor, AppTheme.pineLightAccent);
    });

    test('Builds Pine Slate Dark theme with high-contrast tokens', () {
      final theme = AppTheme.buildTheme(
        palette: AppPalette.pineSlate,
        brightness: Brightness.dark,
      );

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppTheme.pineDarkScaffold);
      expect(theme.colorScheme.onSurface, AppTheme.pineDarkOnSurface);
      expect(theme.colorScheme.primary, AppTheme.pineDarkPrimary);

      final dialExt = theme.extension<DialThemeExtension>();
      expect(dialExt, isNotNull);
      expect(dialExt!.trackColor, AppTheme.pineDarkTrack);
      expect(dialExt.primaryArcColor, AppTheme.pineDarkPrimary);
      expect(dialExt.accentMarkerColor, AppTheme.pineDarkAccent);
    });
  });

  group('StorageService Theme Persistence Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Saves and loads AppPalette accurately', () async {
      expect(await StorageService.loadPalette(), AppPalette.warmUmber);

      await StorageService.savePalette(AppPalette.pineSlate);
      expect(await StorageService.loadPalette(), AppPalette.pineSlate);

      await StorageService.savePalette(AppPalette.warmUmber);
      expect(await StorageService.loadPalette(), AppPalette.warmUmber);
    });

    test('Saves and loads ThemeMode accurately', () async {
      expect(await StorageService.loadThemeMode(), ThemeMode.system);

      await StorageService.saveThemeMode(ThemeMode.dark);
      expect(await StorageService.loadThemeMode(), ThemeMode.dark);

      await StorageService.saveThemeMode(ThemeMode.light);
      expect(await StorageService.loadThemeMode(), ThemeMode.light);
    });

    test('Saves and loads TextureStyle accurately', () async {
      expect(await StorageService.loadTextureStyle(), TextureStyle.grain);

      await StorageService.saveTextureStyle(TextureStyle.dots);
      expect(await StorageService.loadTextureStyle(), TextureStyle.dots);

      await StorageService.saveTextureStyle(TextureStyle.none);
      expect(await StorageService.loadTextureStyle(), TextureStyle.none);
    });
  });
}
