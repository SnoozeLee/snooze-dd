# 高级感设计系统实施计划 (04_theme_color_design.plan.md)

> **关联 Spec**：`specs/features/04_theme_color_design.spec.md`  
> **实施负责人**：AI 视觉架构助手 & 开发者  
> **当前状态**：Done  
> **启动时间**：2026-11-18  

---

## 1. 🎯 实施概览与交付标准 (Deliverable Summary)

- **本次迭代目标**：
  - 交付双配色方案（岩茶金石、松烟墨青）× 双主题模式（亮色、暗色）的纯色高级感色彩体系（100% 拒绝渐变）。
  - 实现实体级背景微质感纹理组件（`TextureBackground`），提供和纸/砂石微噪点与精密点阵两种模式。
  - 重构计时表盘与排版：加粗等宽倒计时主字（`FontWeight.w700~w800`）、圆润端头、大圆角 Squircle 卡片与节点清晰高亮。
  - 彻底杜绝 Unicode 字符作为按钮图标，全线采用精细矢量图标。
  - 支持配置持久化（`StorageService`）与应用内主题设置弹窗（`ThemeSettingDialog`）。
- **质量门禁要求**：
  - [x] 所有新增数据模型与主题计算包含对应单元测试，覆盖率目标 ≥ 80%
  - [x] Flutter 类型与静态分析 0 警告、0 报错 (`flutter analyze`)
  - [x] 现存测试套件全部回归通过 (`flutter test`)

---

## 2. 🪜 任务阶段划分与执行清单 (Phased Task Checklist)

### Phase 1: 主题契约与色彩系统定义 (Contracts & Token Definitions)
- [x] **Task 1.1**: 定义 `AppPalette` 与 `TextureStyle` 枚举，并编写 `AppTheme` 色彩配置与 `ThemeData` 生成器 (`lib/ui/theme/app_theme.dart`)
- [x] **Task 1.2**: 扩展 `StorageService`，支持保存和读取主题配置（`palette`, `themeMode`, `textureStyle`）
- [x] **Task 1.3**: 编写主题配置与序列化单元测试 (`test/ui/app_theme_test.dart`)
  - **验证方式**: `flutter test test/ui/app_theme_test.dart` 全绿通过

### Phase 2: 背景微质感组件与全局状态管理 (Texture & Theme Controller)
- [x] **Task 2.1**: 实现纯色实体微质感组件 `TextureBackground` (`lib/ui/widgets/texture_background.dart`)，使用高性能 `CustomPainter` 绘制和纸微粒与点阵（严格零渐变）
- [x] **Task 2.2**: 实现 `ThemeController` (`lib/ui/theme/theme_controller.dart`)，管理配色、主题模式与纹理切换并驱动全局重绘
- [x] **Task 2.3**: 编写主题控制器测试用例，覆盖切换与持久化

### Phase 3: 表盘重构与矢量组件升级 (High-Contrast & Bold Dial UI)
- [x] **Task 3.1**: 重构 `TimerDial` (`lib/ui/widgets/timer_dial.dart`)：
  - 字体升级：倒计时时间使用 `FontWeight.w800` 等宽粗体，消除模糊感
  - 表盘圆环：加深底轨实色对比度，圆弧起止端点采用 `StrokeCap.round`
  - 节点标牌：放大刻度字体（11px/w700），增加背景实体卡片隔离
- [x] **Task 3.2**: 检查并替换所有界面图标为 Flutter Material Vector 图标（`Icons.xxx`），杜绝任何 Unicode 符号

### Phase 4: 主题切换交互弹窗与入口接入 (Theme Settings UI)
- [x] **Task 4.1**: 实现主题与配色设置面板 `ThemeSettingDialog` (`lib/ui/widgets/theme_setting_dialog.dart`)，支持实时预览与一键切换
- [x] **Task 4.2**: 在 `TimerScreen` 顶栏增加主题切换入口，集成 `ThemeController`
- [x] **Task 4.3**: 在 `main.dart` 接入 `ThemeController` 与动态 `MaterialApp`
- [x] **Task 4.4**: 编写界面 Widget 测试，验证主题切换与弹窗交互

### Phase 5: 质量门禁与回归验证 (Quality Gate & Regression)
- [x] **Task 5.1**: 运行 `flutter analyze`，确保 0 警告、0 错误
- [x] **Task 5.2**: 运行完整 `flutter test`，确保原有 18 个测试与新增主题测试 100% 通过
- [x] **Task 5.3**: 规范化 Git 原子提交与文档进度同步
