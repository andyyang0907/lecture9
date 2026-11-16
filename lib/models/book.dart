import 'package:flutter/material.dart';

/// 藏书模型：收藏列表与详情页共用。
class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.year,
    required this.mark,
    required this.intro,
    required this.coverColors,
  });

  final int id;
  final String title;
  final String author;
  final String category;
  final int year;
  final String mark;
  final String intro;
  final List<Color> coverColors;

  String get heroTag => 'cover-$id';
}
