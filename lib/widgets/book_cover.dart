import 'package:flutter/material.dart';

import '../models/book.dart';

/// 参数化复用组件：书籍封面。列表与详情共用同一视觉，Hero 转场才能无缝衔接。
class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.book,
    required this.width,
    required this.height,
    this.radius = 14,
    this.showTitle = false,
  });

  final Book book;
  final double width;
  final double height;
  final double radius;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: book.coverColors,
        ),
        boxShadow: [
          BoxShadow(
            color: book.coverColors.first.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -10,
            child: Text(
              book.mark,
              style: TextStyle(
                fontFamily: 'Roboto',
                decoration: TextDecoration.none,
                fontSize: showTitle ? 96 : 46,
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
          ),
          Center(
            child: Text(
              book.mark,
              style: TextStyle(
                fontFamily: 'Roboto',
                decoration: TextDecoration.none,
                fontSize: showTitle ? 72 : 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          if (showTitle)
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: Text(
                book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  decoration: TextDecoration.none,
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
