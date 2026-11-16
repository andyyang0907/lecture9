import '../models/book.dart';
import 'book_repository.dart';

/// 课堂案例的数据入口：实际书单统一维护在 [BookRepository]。
const List<Book> books = BookRepository.books;
