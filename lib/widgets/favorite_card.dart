import 'package:flutter/material.dart';

import '../debug/app_metrics.dart';
import '../models/book.dart';
import 'book_cover.dart';

/// 参数化复用组件：收藏列表项。
///
/// 当前版本每个卡片在 initState 里各自创建 AnimationController 做心跳光晕，
/// 这是实践指南九“反例一”的活体版（EX19 同款），待排查修复。
class FavoriteCard extends StatefulWidget {
  const FavoriteCard({
    super.key,
    required this.book,
    required this.favorite,
    required this.onTap,
    required this.onLongPress,
  });

  final Book book;
  final bool favorite;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  State<FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<FavoriteCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    AppMetrics.favoriteCardsBuilt++;
    AppMetrics.controllersCreated++;
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  // 待排查：这里缺少 dispose，页面滚出后控制器仍在每帧空转。

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: widget.book.heroTag,
                  child: BookCover(book: widget.book, width: 72, height: 96),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.book.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          ScaleTransition(
                            scale: Tween<double>(begin: 0.85, end: 1.15)
                                .animate(
                                  CurvedAnimation(
                                    parent: _pulse,
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                            child: Icon(
                              widget.favorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20,
                              color: widget.favorite
                                  ? const Color(0xFFE64980)
                                  : theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.book.author} · ${widget.book.year}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: widget.book.coverColors.first.withValues(
                                alpha: 0.10,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.book.category,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: widget.book.coverColors.first,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '长按收藏',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
