import 'package:flutter/material.dart';
import 'ui/screens/timer_screen.dart';
import 'ui/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController();
  await themeController.init();
  runApp(SnoozeDdApp(themeController: themeController));
}

class SnoozeDdApp extends StatefulWidget {
  final ThemeController? themeController;

  const SnoozeDdApp({super.key, this.themeController});

  @override
  State<SnoozeDdApp> createState() => _SnoozeDdAppState();
}

class _SnoozeDdAppState extends State<SnoozeDdApp> {
  late final ThemeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.themeController ?? ThemeController();
    if (widget.themeController == null) {
      _controller.init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: _controller,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return MaterialApp(
            title: 'SnoozeDD',
            debugShowCheckedModeBanner: false,
            theme: _controller.lightTheme,
            darkTheme: _controller.darkTheme,
            themeMode: _controller.themeMode,
            home: const TimerScreen(),
          );
        },
      ),
    );
  }
}
