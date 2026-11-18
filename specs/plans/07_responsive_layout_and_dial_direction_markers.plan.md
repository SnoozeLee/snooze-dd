# 响应式布局自适应、微质感加深与表盘方向性标记实施计划 (07_responsive_layout_and_dial_direction_markers.plan.md)

> **关联 Spec**：`specs/features/07_responsive_layout_and_dial_direction_markers.spec.md`  
> **实施负责人**：AI 架构助手 & 开发者  
> **当前状态**：Done  
> **启动时间**：2026-11-18  

---

## 1. 🎯 实施概览与交付标准 (Deliverable Summary)

- **本次迭代目标**：
  - 加深微质感（`TextureBackground`），使和纸微粒与点阵清晰可见。
  - 升级 `TimerDial`，在节点标牌上标注 `▶`（正计时）与 `⏳`（倒计时）。
  - 重构 `TimerScreen` 顶部预设栏：将「自定义...」移到最左侧首位。
  - 重构 `TimerScreen` 底部操作栏：添加 `maxWidth: 380px` 约束并居中。
- **质量门禁要求**：
  - [x] 界面与表盘组件测试全部通过
  - [x] Flutter 类型检查 0 报错 (`flutter analyze`)
  - [x] 现存测试套件全部回归通过 (`flutter test`)

---

## 2. 🪜 任务阶段划分与执行清单 (Phased Task Checklist)

### Phase 1: 微质感视觉增强 (Texture Deepening)
- [x] **Task 1.1**: 调整 `TextureBackground` 中的颗粒半径与 alpha 参数 (`lib/ui/widgets/texture_background.dart`)

### Phase 2: 表盘节点方向性标识 (Dial Directional Markers)
- [x] **Task 2.1**: 更新 `DialMarkerHelper` 与 `TimerDial`，在节点标签中增加 `▶` / `⏳` 方向指示符 (`lib/ui/widgets/timer_dial.dart`)

### Phase 3: 响应式宽窄屏布局调控 (Responsive Layout Tuning)
- [x] **Task 3.1**: 将 `TimerScreen` 中「自定义...」入口移至横向滚动条首位 (`lib/ui/screens/timer_screen.dart`)
- [x] **Task 3.2**: 为底部操作栏增加 `maxWidth: 380px` 居中约束 (`lib/ui/screens/timer_screen.dart`)

### Phase 4: 测试与质量门禁 (Verification & Quality Gate)
- [x] **Task 4.1**: 运行 `flutter test`，更新涉及的断言
- [x] **Task 4.2**: 运行 `flutter analyze` 确保 0 警告
- [x] **Task 4.3**: 规范化 Git 原子提交
