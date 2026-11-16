import 'package:flutter/material.dart';

void main() {
  runApp(const AnimateDebugApp());
}

/// 工程骨架：先占位，下一步接入收藏列表。
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
      home: const Scaffold(
        body: Center(child: Text('拾光书房 · 书单准备中')),
      ),
    );
  }
}
