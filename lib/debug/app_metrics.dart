/// 调试探针：统计动画控制器的创建与释放，用于给报告留下可复现的量化证据。
class AppMetrics {
  AppMetrics._();

  static int controllersCreated = 0;
  static int controllersDisposed = 0;
  static int favoriteCardsBuilt = 0;

  static void reset() {
    controllersCreated = 0;
    controllersDisposed = 0;
    favoriteCardsBuilt = 0;
  }
}
