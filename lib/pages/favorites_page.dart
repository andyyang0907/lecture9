import 'package:flutter/material.dart';

import '../data/book_repository.dart';
import '../models/book.dart';
import '../widgets/favorite_card.dart';

/// 收藏列表页：长按收藏、点击进详情。
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final Set<int> _favorites = {1, 3};
  late bool _offline = AppSettings.simulateOffline;

  void _toggleFavorite(Book book) {
    setState(() {
      if (!_favorites.add(book.id)) {
        _favorites.remove(book.id);
      }
    });
    final added = _favorites.contains(book.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 900),
          content: Text(added ? '已收藏《${book.title}》' : '已取消收藏《${book.title}》'),
        ),
      );
  }

  void _toggleOffline() {
    setState(() {
      _offline = !_offline;
      AppSettings.simulateOffline = _offline;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          content: Text(_offline ? '已开启模拟断网，打开详情会加载失败' : '已恢复网络'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('拾光书房'),
            Text(
              '长按卡片收藏 · 点击查看详情',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _offline ? '关闭模拟断网' : '模拟断网',
            onPressed: _toggleOffline,
            icon: Icon(_offline ? Icons.wifi_off_rounded : Icons.wifi_rounded),
            color: _offline ? theme.colorScheme.error : null,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _favorites.isEmpty
                    ? [
                        theme.colorScheme.surfaceContainerHighest,
                        theme.colorScheme.surfaceContainerHigh,
                      ]
                    : [const Color(0xFF5F3DC4), const Color(0xFF7048E8)],
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  color: _favorites.isEmpty
                      ? theme.colorScheme.onSurfaceVariant
                      : Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '我的收藏',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: _favorites.isEmpty
                              ? theme.colorScheme.onSurfaceVariant
                              : Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Text(
                              '${_favorites.length}',
                              key: ValueKey(_favorites.length),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: _favorites.isEmpty
                                    ? theme.colorScheme.onSurfaceVariant
                                    : Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3, left: 4),
                            child: Text(
                              '/ ${BookRepository.books.length} 本',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _favorites.isEmpty
                                    ? theme.colorScheme.onSurfaceVariant
                                    : Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  _favorites.isEmpty ? '长按收藏第一本' : '继续长按收藏',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _favorites.isEmpty
                        ? theme.colorScheme.onSurfaceVariant
                        : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: BookRepository.books.length,
              itemBuilder: (context, index) {
                final book = BookRepository.books[index];
                return FavoriteCard(
                  book: book,
                  favorite: _favorites.contains(book.id),
                  onTap: () =>
                      Navigator.pushNamed(context, '/detail', arguments: book),
                  onLongPress: () => _toggleFavorite(book),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
