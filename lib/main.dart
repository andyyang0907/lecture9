import 'package:flutter/material.dart';

import 'pages/book_detail_page.dart';
import 'pages/favorites_page.dart';

void main() {
  runApp(const AnimateDebugApp());
}

/// 第 9 课课堂案例 animate_debug：收藏列表 + Hero 详情 + 两处待排查问题。
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
      routes: {
        '/': (_) => const FavoritesPage(),
        '/detail': (_) => const BookDetailPage(),
      },
      initialRoute: '/',
    );
  }
}
