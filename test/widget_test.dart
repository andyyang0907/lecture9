import 'package:animate_debug/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('应用启动后展示收藏列表', (tester) async {
    await tester.pumpWidget(const AnimateDebugApp());
    await tester.pumpAndSettle();

    expect(find.text('拾光书房'), findsOneWidget);
    expect(find.text('Flutter实战'), findsOneWidget);
  });
}
