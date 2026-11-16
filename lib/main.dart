import 'package:flutter/material.dart';

import 'pages/favorites_page.dart';

void main() {
  runApp(const AnimateDebugApp());
}

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
      },
      initialRoute: '/',
    );
  }
}
