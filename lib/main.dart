import 'dart:async';

import 'package:flutter/material.dart';

import 'pages/book_detail_page.dart';
import 'pages/favorites_page.dart';
import 'services/error_reporter.dart';
import 'widgets/global_error_banner.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorReporter.instance.installGlobalHandlers();
  runZonedGuarded(
    () => runApp(const AnimateDebugApp()),
    (error, stack) => ErrorReporter.instance.report(
      error,
      context: 'Zone 未捕获异常',
      stack: stack,
    ),
  );
}

/// 第 9 课课堂案例 animate_debug：收藏列表 + Hero 详情 + 全局异常捕获。
class AnimateDebugApp extends StatelessWidget {
  const AnimateDebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '拾光书房',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF5F3DC4),
        useMaterial3: true,
      ),
      builder: (context, child) {
        // 错误条贴在 AppBar 下方，避免遮挡导航栏操作。
        final topInset = MediaQuery.paddingOf(context).top + kToolbarHeight + 8;
        return Stack(
          children: [
            ?child,
            Positioned(
              top: topInset,
              left: 0,
              right: 0,
              child: const GlobalErrorBanner(),
            ),
          ],
        );
      },
      routes: {
        '/': (_) => const FavoritesPage(),
        '/detail': (_) => const BookDetailPage(),
      },
      initialRoute: '/',
    );
  }
}
