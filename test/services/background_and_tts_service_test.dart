import 'package:flutter_test/flutter_test.dart';
import 'package:snooze_dd/services/background_service.dart';
import 'package:snooze_dd/services/tts_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BackgroundService & TtsService Specifications Tests', () {
    test('BackgroundService singleton maintains safe initial state', () {
      final service1 = BackgroundService();
      final service2 = BackgroundService();
      expect(identical(service1, service2), isTrue);
      expect(service1.isRunning, isFalse);
    });

    test('TtsService singleton maintains safe queue and initialization state', () async {
      final tts1 = TtsService();
      final tts2 = TtsService();
      expect(identical(tts1, tts2), isTrue);
      expect(tts1.isSpeaking, isFalse);
    });

    test('TtsService speak handles empty or whitespace text gracefully', () async {
      final tts = TtsService();
      await tts.speak('');
      await tts.speak('   ');
      expect(tts.isSpeaking, isFalse);
    });
  });
}
