# 自由设置总时长 & 圆弧节点标记交互 实施计划 (Implementation Plan)

> **关联 Spec**：[specs/features/02_custom_duration_and_dial_checkpoints.spec.md](specs/features/02_custom_duration_and_dial_checkpoints.spec.md)  
> **实施负责人**：AI 编程助手 & 开发者  
> **技术栈**：Flutter (Dart)  
> **当前状态**：✅ Completed (All Tasks Delivered)  
> **启动时间**：2026-11-17  

---

## 1. 🎯 实施概览与交付标准 (Deliverable Summary)

- **本次迭代目标**：交付两个增强特性 — 滚轮拨盘自由设定总时长 + 圆弧 Checkpoint 标记可视化与点击编辑气泡。
- **质量门禁要求**：
  - [x] Dart 分析器 0 警告 0 报错 (`flutter analyze`)
  - [x] 核心组件单元测试覆盖并通过 (`flutter test`)
  - [x] 严格原子化 Git 提交（每个 Phase 独立提交）

---

## 2. 🪜 任务阶段划分与执行清单 (Phased Task Checklist)

### Phase 1: 滚轮拨盘时长选择器 (Duration Picker Widget)
- [x] **Task 1.1**: 创建 `lib/ui/widgets/duration_picker_sheet.dart` — 底部弹出的滚轮拨盘组件
  - 包含「小时」(0~2) 和「分钟」(0~59) 两列 CupertinoPicker
  - 最小值锁定为 1 分钟，最大值 180 分钟
  - 底部确认/取消按钮
  - 顶部快捷预设按钮行（15/25/45/60/90 分钟，一键选取跳转滚轮位置）
- [x] **Task 1.2**: 修改 `timer_screen.dart` — 替换 FilterChip 预设行为新的时长显示区 + 点击打开拨盘
  - 显示当前时长文字（如 "33 分钟"）可点击触发拨盘
  - 保留直观的快捷预设入口
  - 计时 running 时禁用入口
- [x] **Task 1.3**: 实现节点越界保护逻辑
  - 时长缩短后扫描 Checkpoint 列表，自动禁用越界节点
  - 弹出 SnackBar 提示用户
- **验证方式**: 手动测试滚轮交互 + `flutter analyze` 通过

### Phase 2: 圆弧节点标记渲染 (Dial Checkpoint Markers)
- [x] **Task 2.1**: 重构 `timer_dial.dart` — 从 `CircularProgressIndicator` 改为 `CustomPainter`
  - 绘制背景轨道弧
  - 绘制进度弧
  - 新增 Checkpoint 标记绘制：小圆点 + 时间标签
  - 实现标签防重叠逻辑（角度差 < 15° 时隐藏文字）
- [x] **Task 2.2**: 传入 Checkpoint 列表与已触发 ID 集合
  - 在 `TimerScreen` 中将 `session.checkpoints` 和 `triggeredCheckpointIds` 传递给 `TimerDial`
  - 标记样式三态：启用未触发（主题色）、已触发（灰色+✓）、禁用（半透明）
- [x] **Task 2.3**: 编写标记定位算法单元测试
  - 测试角度计算公式正确性
  - 测试防重叠逻辑
- **验证方式**: `flutter test` 通过 + 视觉验收标记位置正确

### Phase 3: 气泡卡片点击编辑 (Popover Checkpoint Editor)
- [x] **Task 3.1**: 实现圆弧标记点击命中检测
  - `TimerDial` 在内部包装 `GestureDetector`
  - 通过触摸坐标计算最近的标记点，命中半径阈值 28px
  - 回调通知点击了哪个 Checkpoint
- [x] **Task 3.2**: 创建 `lib/ui/widgets/checkpoint_popover.dart` — 轻量气泡卡片
  - 弹出展示（`CheckpointPopover.show`）
  - 显示：节点触发时间、播报文案（可内联编辑的 TextField）、启用开关、删除按钮
  - 点击取消或背景关闭
- [x] **Task 3.3**: 连通气泡编辑操作到 `TimerScreen` 状态管理
  - 修改文案 → 更新 `_session.checkpoints` → 持久化
  - 切换开关 → 同上
  - 删除节点 → 同上，标记即时消失
- **验证方式**: 单元测试覆盖 + `flutter analyze` 通过

### Phase 4: 集成测试与验收 (Integration & Sign-off)
- [x] **Task 4.1**: 对照 Spec 中 5 个 BDD 验收场景逐项验证
- [x] **Task 4.2**: 更新 Spec 文档状态为 `Completed`
- [x] **Task 4.3**: 更新本计划文档，勾选所有完成项

---

## 3. 🔍 核心验证命令清单 (Verification Commands)

```bash
# 1. 静态代码分析与类型检查
flutter analyze

# 2. 执行单元测试
flutter test

# 3. 本地编译与运行调试
flutter run
```

---

## 4. 📂 文件变更清单 (Files Affected)

| 操作 | 文件路径 | 说明 |
| :--- | :--- | :--- |
| **新建** | `lib/ui/widgets/duration_picker_sheet.dart` | 滚轮拨盘时长选择器组件 |
| **新建** | `lib/ui/widgets/checkpoint_popover.dart` | 节点气泡卡片编辑组件 |
| **修改** | `lib/ui/widgets/timer_dial.dart` | 重构为 CustomPainter + 标记渲染与命中检测 |
| **修改** | `lib/ui/screens/timer_screen.dart` | 集成拨盘、传递标记数据、气泡回调与越界保护 |
| **新建** | `test/ui/timer_dial_markers_test.dart` | 标记定位算法与交互单元测试 |
| **新建** | `test/ui/checkpoint_popover_test.dart` | 拨盘与气泡卡片 Widget 测试 |
