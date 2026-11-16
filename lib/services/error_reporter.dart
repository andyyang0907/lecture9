import 'dart:ui';

import 'package:flutter/material.dart';

/// 一次被捕获的错误：界面用它渲染错误条，报告用它留痕。
class AppError {
  const AppError({
    required this.context,
    required this.message,
    required this.time,
  });

  final String context;
  final String message;
  final DateTime time;
}

/// 全局错误收集器：
/// - FlutterError.onError 接框架同步异常；
/// - PlatformDispatcher.instance.onError 接未捕获的异步/平台异常；
/// - runZonedGuarded 兜底 zone 内异常。
class ErrorReporter {
  ErrorReporter._();

  static final ErrorReporter instance = ErrorReporter._();

  final ValueNotifier<AppError?> lastError = ValueNotifier<AppError?>(null);

  void report(Object error, {String context = '应用异常', StackTrace? stack}) {
    debugPrint('[$context] $error');
    if (stack != null) {
      debugPrint('$stack');
    }
    lastError.value = AppError(
      context: context,
      message: error.toString().replaceFirst('Exception: ', ''),
      time: DateTime.now(),
    );
  }

  void clear() {
    lastError.value = null;
  }

  /// 应用启动时挂一次，之后所有未捕获异常都会落到 lastError。
  void installGlobalHandlers() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      report(details.exception, context: 'Flutter 框架异常', stack: details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      report(error, context: '未捕获的异步异常', stack: stack);
      return true;
    };
  }
}
