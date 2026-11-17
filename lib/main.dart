import 'package:flutter/material.dart';
import 'ui/screens/timer_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SnoozeDdApp());
}

class SnoozeDdApp extends StatelessWidget {
  const SnoozeDdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnoozeDD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E), // 雅致专注绿 (Calm Teal)
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const TimerScreen(),
    );
  }
}
