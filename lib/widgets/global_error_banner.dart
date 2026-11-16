import 'package:flutter/material.dart';

import '../services/error_reporter.dart';

/// 界面内错误条：任何上报到 ErrorReporter 的异常都会从顶部滑入。
class GlobalErrorBanner extends StatelessWidget {
  const GlobalErrorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppError?>(
      valueListenable: ErrorReporter.instance.lastError,
      builder: (context, error, _) {
        return IgnorePointer(
          ignoring: error == null,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            offset: error == null ? const Offset(0, -1.4) : Offset.zero,
            child: error == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Material(
                      key: const Key('global-error-banner'),
                      color: const Color(0xFFB42318),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    error.context,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    error.message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Semantics(
                              label: '关闭错误提示',
                              button: true,
                              child: IconButton(
                                onPressed: ErrorReporter.instance.clear,
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
