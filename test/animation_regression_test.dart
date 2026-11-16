import 'package:animate_debug/data/book_repository.dart';
import 'package:animate_debug/debug/app_metrics.dart';
import 'package:animate_debug/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 问题一的回归测试：动画控制器不再由列表项逐个创建。
void main() {
  setUp(() {
    AppSettings.simulateOffline = false;
    AppMetrics.reset();
  });

  testWidgets('列表滚动不创建逐项 AnimationController', (tester) async {
    await tester.pumpWidget(const AnimateDebugApp());
    await tester.pumpAndSettle();

    expect(AppMetrics.controllersCreated, 0);

    for (var i = 0; i < 3; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pumpAndSettle();
    }

    expect(AppMetrics.controllersCreated, 0, reason: '收藏高亮改用隐式动画后，滚动不应再创建控制器');
  });

  testWidgets('详情页只创建一个渐显控制器，返回时释放', (tester) async {
    await tester.pumpWidget(const AnimateDebugApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Flutter实战'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(AppMetrics.controllersCreated, 1);
    expect(AppMetrics.controllersDisposed, 0);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(AppMetrics.controllersDisposed, 1);
  });
}
