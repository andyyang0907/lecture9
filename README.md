# animate_debug（课堂作业九）

第 9 课课堂案例复现 + 自主实践：**收藏列表（长按收藏动画）→ Hero 详情（渐显进入、简介展开）**，并在基线里复现、定位、修复两处真实问题：列表项逐项创建动画控制器、断网时详情页静默白屏。

## 运行

```bash
flutter pub get
flutter run -d chrome     # 或 flutter run -d <设备 id>
flutter test              # 13 个测试（行为 + 回归 + 截图）
```

截图由 golden 测试生成：

```bash
flutter test test/screenshot_test.dart --update-goldens
```

## 目录结构

```
lib/
├── main.dart                     # MaterialApp + 路由 + 全局异常三层网入口
├── models/book.dart              # Book 模型（含 Hero tag）
├── data/
│   ├── book_repository.dart      # 12 本藏书 + 模拟断网开关 + 延迟请求
│   └── book_data.dart            # 数据入口别名
├── pages/
│   ├── favorites_page.dart       # 收藏列表：隐式摘要动画 + 长按收藏
│   └── book_detail_page.dart     # 详情：Hero + 渐显 + 简介展开 + 错误态/重试
├── services/error_reporter.dart  # FlutterError / PlatformDispatcher / Zone 三层捕获
├── debug/app_metrics.dart        # 调试探针：控制器创建/释放计数
└── widgets/
    ├── book_cover.dart           # 参数化复用组件：封面（Hero 载体）
    ├── favorite_card.dart        # 参数化复用组件：收藏卡片
    └── global_error_banner.dart  # 界面内全局错误条
docs/
└── screenshots/                  # 报告截图（golden 生成）
test/
├── app_flow_test.dart            # 长按收藏、Hero 标签、简介展开
├── animation_regression_test.dart# 问题一回归：滚动不再创建控制器
├── error_handling_test.dart      # 问题二回归：断网错误条 + 重试
├── screenshot_test.dart          # 生成报告截图
└── widget_test.dart              # 启动冒烟测试
```

## 两处问题的“现象 → 工具 → 原因 → 修复”

### 问题一：滚动列表闪烁、越滚越卡

- **现象**：上下滚动收藏列表时部分卡片高亮闪动，滚动越久越卡。
- **工具**：调试探针 `AppMetrics` 计数 + 卸载时的 Ticker 断言（等价于 Inspector 的 Highlight rebuilds 量化思路）。
- **基线数据**：首屏 6 张卡片创建 6 个控制器；滚动三次后卡片 12、控制器 12、释放 0；列表卸载时报 `_FavoriteCardState was disposed with an active Ticker`。
- **原因**：`FavoriteCard` 每个条目在 `initState` 里各自 `new AnimationController()..repeat()`，滚动时反复创建/销毁，动画从头播放，且没有释放。
- **修复**：删除逐项控制器，收藏高亮改为隐式动画 `AnimatedScale`（框架托管生命周期）；滚动再多次创建数保持 0。提交 `fix: hoist heavy objects out of itemBuilder`。

### 问题二：断网时详情页静默白屏

- **现象**：开启模拟断网后打开详情，页面一直转圈；控制台只有一行 `debugPrint`，界面没有任何反馈。
- **工具**：探针测试 + 控制台日志。
- **基线数据**：断网 1.2 秒后 `加载圈=true 错误提示=false 重试入口=false`。
- **原因**：`catch` 里只 `debugPrint`，没有 `setState` 切错误态，用户无路可走。
- **修复**：接住 → `ErrorReporter.report` 上报 → 界面错误卡片 + 全局错误条 + 重试按钮；重试成功自动清除错误条。同时挂载 `FlutterError.onError`、`PlatformDispatcher.instance.onError` 与 `runZonedGuarded` 三层网。提交 `fix: global error capture + analyze clean`。

## 动画改造（自主实践）

| 类型 | 位置 | 说明 |
| --- | --- | --- |
| 隐式动画 | 收藏摘要卡 | `AnimatedContainer` 渐变随收藏数变化，`AnimatedSwitcher` 数字缩放切换 |
| 隐式动画 | 收藏心形 | `AnimatedScale` 收藏前后缩放，无控制器 |
| 隐式动画 | 详情简介 | `AnimatedSize` 展开/收起，`AnimatedRotation` 箭头翻转 |
| 隐式动画 | 全局错误条 | `AnimatedSlide` 从顶部滑入 |
| Hero 转场 | 列表 ↔ 详情 | 两页同 `tag: 'cover-$id'`，列表卡片与详情封面连续过渡 |
| 显式动画 | 详情内容 | `AnimationController + CurvedAnimation` 渐显，`dispose` 正确释放 |

## 质量检查

| 检查项 | 结果 |
| --- | --- |
| `flutter test` | 13 项全部通过 |
| `flutter analyze` | 0 issues（在 ASCII 路径副本中运行，见报告“问题与调试”记录 3） |
| `dart format` | 15 个文件，0 changed |
| 错误捕获 | 框架异常 / 异步异常 / Zone 异常三层均已挂载 |
| 运行目标 | Chrome（Web）为主，android / ios 工程保留 |

## 进度报告

十节正文见仓库根目录 `progress.md`，截图在 `docs/screenshots/`。

## 提交记录

| 提交 | 内容 |
| --- | --- |
| `feat: scaffold project and add book data` | 工程骨架、Book 模型、12 本模拟书单、断网开关与调试计数 |
| `feat: build favorites list with cover cards` | 收藏列表、参数化封面卡片、长按收藏（保留逐项控制器问题） |
| `feat: add Hero detail page with fade-in` | Hero 详情、内容渐显、简介加载（保留静默 catch 问题） |
| `fix: stabilize list animations and surface load errors` | 隐式动画替换逐项控制器；三层异常捕获、错误条与重试；两组回归测试 |
| `test & docs: add tests, screenshots and report` | 主流程测试、6 张 golden 截图、README 与进度报告 |

## AI 使用标注

本项目由本人主导完成：需求拆解、技术选型、问题定位方向、测试验收、截图目检、提交拆分与最终结论均由本人负责；Trae（DeepSeek-V4.1-Flash）作为辅助工具，承担代码与文字初稿。具体分工如下：

| 环节 | 本人的主导工作 | AI 的辅助 | 本人的验收与取舍 |
| --- | --- | --- | --- |
| 需求拆解 | 读实践指南九与课堂幻灯片，列出验收清单：两处问题必须可复现、Hero tag 同屏唯一、`analyze` 0、`format` 全量 | 按清单搭两页骨架与目录 | 不接受“只改代码不取证”，坚持先复现再修 |
| 数据与页面 | 定 Book 字段、12 本书单、列表/详情的信息层级与文案 | 生成模型、模拟仓库与页面初稿 | 逐页对照检查点，调整卡片间距与摘要卡信息 |
| 问题一 | 从滚动卡顿与闪烁判断“每个条目都在建控制器”，要求量化 | 加 `AppMetrics` 探针与复现测试 | 看到 6→12、释放 0 后，决定不用“上提控制器”，改用隐式动画 |
| 问题二 | 明确 `catch` 必须有界面出口，不接受只 `debugPrint` | 写 `ErrorReporter`、错误条与错误卡片 | 设计“断网→恢复网络→重试成功”的验收路径并跑通 |
| 动画改造 | 选 `AnimatedSize`/`AnimatedRotation` 做简介展开，Hero 用 `cover-$id` | 生成动画初稿与测试 | 断言 tag 唯一、`maxLines` 3→null，确认不是“看起来像” |
| 截图排错 | 逐张目检截图，发现封面方块与 Hero 黄色下划线 | 按反馈改字体与 `decoration` | 重新生成 6 张截图并确认干净 |
| 提交与报告 | 定 5 次提交的拆分、时间线与报告结论 | 整理 README/报告文字与命令摘录 | 核对远程提交时间，修正未来时间戳问题 |

标注原则：AI 是“实现助手”，不是项目作者。AI 生成的代码与文字均经过本人运行、对照或修改后才采用；书单内容、页面文案与自评结论为本人整理。
