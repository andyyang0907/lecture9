import 'package:animate_debug/data/book_repository.dart';
import 'package:animate_debug/main.dart';
import 'package:animate_debug/services/error_reporter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 问题二的回归测试：断网 → 错误条 + 重试 → 恢复网络后加载成功。
void main() {
  setUp(() {
    AppSettings.simulateOffline = false;
    ErrorReporter.instance.clear();
  });

  tearDown(() {
    AppSettings.simulateOffline = false;
    ErrorReporter.instance.clear();
  });

  testWidgets('断网时显示错误条与重试入口，恢复网络后重试成功', (tester) async {
    AppSettings.simulateOffline = true;

    await tester.pumpWidget(const AnimateDebugApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flutter实战'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    // 1. 不再无限转圈：出现错误卡片与全局错误条。
    expect(find.byKey(const Key('detail-error')), findsOneWidget);
    expect(find.text('简介加载失败'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    expect(find.byKey(const Key('global-error-banner')), findsOneWidget);

    // 2. 恢复网络后点“重试”，简介加载成功，错误态消失。
    await tester.tap(find.byKey(const Key('detail-offline-toggle')));
    await tester.pumpAndSettle();
    expect(AppSettings.simulateOffline, isFalse);
    await tester.tap(find.text('重试'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('detail-error')), findsNothing);
    expect(find.byKey(const Key('global-error-banner')), findsNothing);
    expect(find.textContaining('本书由浅入深地讲解 Flutter'), findsOneWidget);
  });

  testWidgets('上报异常后全局错误条出现，点关闭后消失', (tester) async {
    await tester.pumpWidget(const AnimateDebugApp());
    await tester.pumpAndSettle();

    ErrorReporter.instance.report('模拟未捕获异常', context: '测试上报');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('global-error-banner')), findsOneWidget);
    expect(find.text('模拟未捕获异常'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('global-error-banner')), findsNothing);
  });
}
