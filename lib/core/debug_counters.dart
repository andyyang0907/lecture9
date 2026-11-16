/// 调试探针：把“谁在创建动画控制器”变成可断言的数字。
///
/// 这是本课“先量化、再优化”的落点：修复前 itemBuilder 每构建一次就 new 一个
/// AnimationController，计数器会随滚动持续上涨；修复后只有页面级共享控制器，
/// 滚动再多次也只创建 1 个。
class DebugCounters {
  DebugCounters._();

  /// 页面级共享控制器创建次数。
  static int sharedControllersCreated = 0;

  /// 页面级共享控制器释放次数。
  static int sharedControllersDisposed = 0;

  /// itemBuilder 内创建的控制器次数（修复目标：保持 0）。
  static int itemControllersCreated = 0;

  static void reset() {
    sharedControllersCreated = 0;
    sharedControllersDisposed = 0;
    itemControllersCreated = 0;
  }
}
