import 'package:flutter/material.dart';

import '../debug/app_metrics.dart';
import '../models/book.dart';
import 'book_cover.dart';

/// 参数化复用组件：收藏列表项。
///
/// 修复后不再为每个条目创建 AnimationController：
/// 收藏高亮交给隐式动画 AnimatedScale / AnimatedContainer，生命周期由框架托管，
/// 列表滚动时不会反复创建、销毁控制器，也不会因动画重建而闪烁。
class FavoriteCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    AppMetrics.favoriteCardsBuilt++;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: favorite ? const Color(0xFFF3F0FF) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: book.heroTag,
                  child: BookCover(book: book, width: 72, height: 96),
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
                              book.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          AnimatedScale(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOutBack,
                            scale: favorite ? 1.15 : 0.9,
                            child: Icon(
                              favorite ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: favorite
                                  ? const Color(0xFFE64980)
                                  : theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${book.author} · ${book.year}',
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
                              color: book.coverColors.first.withValues(
                                alpha: 0.10,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              book.category,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: book.coverColors.first,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            favorite ? '已收藏' : '长按收藏',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: favorite
                                  ? const Color(0xFFE64980)
                                  : theme.colorScheme.outline,
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
