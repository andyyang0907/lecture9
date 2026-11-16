import 'package:flutter/material.dart';

import '../data/book_repository.dart';
import '../models/book.dart';
import '../widgets/book_cover.dart';

/// 详情页：Hero 封面 + 内容渐显。
class BookDetailPage extends StatefulWidget {
  const BookDetailPage({super.key});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  late Book _book;
  bool _ready = false;
  bool _loading = true;
  String? _detail;
  late bool _offline = AppSettings.simulateOffline;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) {
      return;
    }
    _ready = true;
    _book = ModalRoute.of(context)!.settings.arguments! as Book;
    _load();
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final text = await BookRepository.instance.fetchDetail(_book);
      if (!mounted) {
        return;
      }
      setState(() {
        _detail = text;
        _loading = false;
      });
    } catch (error) {
      // 待排查：这里只打印，没有切换错误态，界面会一直转圈。
      debugPrint('详情加载失败：$error');
    }
  }

  void _toggleOffline() {
    setState(() {
      _offline = !_offline;
      AppSettings.simulateOffline = _offline;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_book.title),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: _book.heroTag,
              child: BookCover(
                book: _book,
                width: double.infinity,
                height: 240,
                radius: 0,
                showTitle: true,
              ),
            ),
            FadeTransition(
              opacity: CurvedAnimation(parent: _fade, curve: Curves.easeOut),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _book.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_book.author} · ${_book.year}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Chip(
                          label: Text(_book.category),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          avatar: const Icon(Icons.schedule, size: 16),
                          label: const Text('约 6 分钟读完'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '内容简介',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text('正在加载简介…'),
                            ],
                          ),
                        ),
                      )
                    else
                      Text(
                        _detail ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.7,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
