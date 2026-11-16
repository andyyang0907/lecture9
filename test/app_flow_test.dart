import 'package:animate_debug/data/book_repository.dart';
import 'package:animate_debug/main.dart';
import 'package:animate_debug/pages/book_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 主流程行为测试：收藏交互、Hero 转场、简介展开。
void main() {
  setUp(() {
    AppSettings.simulateOffline = false;
  });

  testWidgets('长按卡片收藏：计数与心形状态同步更新', (tester) async {
    await tester.pumpWidget(const AnimateDebugApp());
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);

    await tester.longPress(find.text('活着'));
    await tester.pumpAndSettle();

    expect(find.text('3'), findsOneWidget);
    expect(find.text('已收藏'), findsNWidgets(3));
    expect(
      find.byType(AnimatedScale),
      findsWidgets,
      reason: '收藏高亮使用隐式动画 AnimatedScale',
    );
  });

  testWidgets('列表 → 详情：Hero 标签一致，简介可展开收起', (tester) async {
    await tester.pumpWidget(const AnimateDebugApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Flutter实战'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    final heroInDetail = find.descendant(
      of: find.byType(BookDetailPage),
      matching: find.byWidgetPredicate(
        (widget) => widget is Hero && widget.tag == 'cover-1',
      ),
    );
    expect(heroInDetail, findsOneWidget);
    expect(find.text('亢少军 · 2022'), findsOneWidget);

    final intro = find.textContaining('本书由浅入深地讲解 Flutter');
    expect(tester.widget<Text>(intro).maxLines, 3);

    await tester.tap(find.text('展开'));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(intro).maxLines, isNull);
    expect(find.text('收起'), findsOneWidget);

    await tester.tap(find.text('收起'));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(intro).maxLines, 3);
  });
}
