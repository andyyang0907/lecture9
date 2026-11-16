import 'dart:io';

import 'package:animate_debug/data/book_repository.dart';
import 'package:animate_debug/main.dart';
import 'package:animate_debug/services/error_reporter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 生成报告截图（golden），配合：
///   flutter test test/screenshot_test.dart --update-goldens
/// 图片写到 docs/screenshots/。
void main() {
  setUpAll(() async {
    final cjk = File('/System/Library/Fonts/Supplemental/Arial Unicode.ttf')
        .readAsBytesSync();
    final icons = File(
      '/opt/homebrew/share/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ).readAsBytesSync();
    await (FontLoader(
      'Roboto',
    )..addFont(Future.value(ByteData.view(cjk.buffer)))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(Future.value(ByteData.view(icons.buffer)))).load();
  });

  setUp(() {
    AppSettings.simulateOffline = false;
    ErrorReporter.instance.clear();
  });

  tearDown(() {
    AppSettings.simulateOffline = false;
    ErrorReporter.instance.clear();
  });

  void usePhoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('01 list', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(const AnimateDebugApp());
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../docs/screenshots/01-list.png'),
    );
  });

  testWidgets('02 favorites', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(const AnimateDebugApp());
    await tester.pumpAndSettle();
    await tester.longPress(find.text('活着'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../docs/screenshots/02-favorites.png'),
    );
  });

  testWidgets('03 hero flight', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(const AnimateDebugApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flutter实战'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../docs/screenshots/03-hero-flight.png'),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('04 detail', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(const AnimateDebugApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flutter实战'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../docs/screenshots/04-detail.png'),
    );
  });

  testWidgets('05 detail expanded', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(const AnimateDebugApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flutter实战'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    await tester.tap(find.text('展开'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../docs/screenshots/05-detail-expanded.png'),
    );
  });

  testWidgets('06 offline error', (tester) async {
    usePhoneSize(tester);
    AppSettings.simulateOffline = true;
    await tester.pumpWidget(const AnimateDebugApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flutter实战'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../docs/screenshots/06-offline-error.png'),
    );
  });
}
