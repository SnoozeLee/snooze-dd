import 'package:flutter_test/flutter_test.dart';
import 'package:snooze_dd/main.dart';

void main() {
  testWidgets('SnoozeDdApp smoke test renders TimerScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const SnoozeDdApp());
    await tester.pumpAndSettle();

    // 校验应用标题及默认番茄钟组件存在
    expect(find.text('专注番茄钟'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('开始'), findsOneWidget);
  });
}
