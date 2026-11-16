import 'package:flutter/material.dart';

import '../data/book_repository.dart';
import '../debug/app_metrics.dart';
import '../models/book.dart';
import '../services/error_reporter.dart';
import '../widgets/book_cover.dart';

/// 详情页：Hero 封面 + 内容渐显 + 简介展开（隐式动画）+ 错误态与重试。
class BookDetailPage extends StatefulWidget {
  const BookDetailPage({super.key});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade;

  late Book _book;
  bool _ready = false;
  bool _loading = true;
  String? _detail;
  String? _error;
  bool _expanded = false;
  late bool _offline = AppSettings.simulateOffline;

  @override
  void initState() {
    super.initState();
    AppMetrics.controllersCreated++;
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

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
    AppMetrics.controllersDisposed++;
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final text = await BookRepository.instance.fetchDetail(_book);
      if (!mounted) {
        return;
      }
      ErrorReporter.instance.clear();
      setState(() {
        _detail = text;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      // 修复后：接住错误 → 上报 → 切换界面错误态，并提供重试入口。
      ErrorReporter.instance.report(error, context: '详情页加载失败');
      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
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
            key: const Key('detail-offline-toggle'),
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
                    Row(
                      children: [
                        Text(
                          '内容简介',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        if (!_loading && _error == null)
                          TextButton(
                            onPressed: () =>
                                setState(() => _expanded = !_expanded),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedRotation(
                                  turns: _expanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 240),
                                  curve: Curves.easeOutCubic,
                                  child: const Icon(
                                    Icons.expand_more_rounded,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(_expanded ? '收起' : '展开'),
                              ],
                            ),
                          ),
                      ],
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
                    else if (_error != null)
                      _ErrorCard(
                        message: _error!,
                        offline: _offline,
                        onRetry: _load,
                      )
                    else
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        alignment: Alignment.topCenter,
                        child: Text(
                          _detail ?? '',
                          maxLines: _expanded ? null : 3,
                          overflow: _expanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.7,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
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

/// 详情页内的错误卡片：错误原因 + 重试按钮，替换此前的“只打印不处理”。
class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.offline,
    required this.onRetry,
  });

  final String message;
  final bool offline;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('detail-error'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 20,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                '简介加载失败',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message, style: theme.textTheme.bodySmall),
          if (offline) ...[
            const SizedBox(height: 6),
            Text(
              '当前仍处于模拟断网状态：点右上角 Wi-Fi 图标恢复网络后再重试。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }
}
