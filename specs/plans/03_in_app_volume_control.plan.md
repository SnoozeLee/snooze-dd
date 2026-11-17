# SnoozeDD 应用内 5 级音量调节 实施计划 (Implementation Plan)

> **关联 Spec**：[specs/features/03_in_app_volume_control.spec.md](specs/features/03_in_app_volume_control.spec.md)  
> **实施负责人**：AI 编程助手 & 开发者  
> **技术栈**：Flutter (Dart)  
> **当前状态**：✅ Completed (All Delivered)  
> **启动时间**：2026-11-17  

---

## 1. 🎯 实施概览与交付标准

- **本次迭代目标**：交付应用内 5 级离散独立音量控制组件、主界面入口、试听与持久化机制。
- **质量门禁**：
  - [x] Dart 分析器 0 警告 0 报错 (`flutter analyze`)
  - [x] 核心功能与组件单元测试全部通过 (`flutter test`)
  - [x] 严格遵循原子化提交规范

---

## 2. 🪜 任务阶段划分与执行清单

### Phase 1: 5 级音量等级定义与转换工具
- [x] **Task 1.1**: 在 `lib/models/timer_session.dart` 提供 `VolumeLevel` 与标量转换函数
- [x] **Task 1.2**: 编写音量档位映射单元测试

### Phase 2: 应用内音量调节组件与弹窗
- [x] **Task 2.1**: 创建 `lib/ui/widgets/volume_setting_dialog.dart` 组件
  - 5 档分段器与说明标签
  - 动态音量图标
  - 「试听当前音量」按钮（伴随音 + 简短测试播报）
  - 保存 / 取消
- [x] **Task 2.2**: 编写音量组件 Widget 测试

### Phase 3: 主界面集成与播放联动
- [x] **Task 3.1**: 在 `TimerScreen` AppBar 新增音量控制图标
- [x] **Task 3.2**: 联动 `StorageService` 与 `TimerSession.volume` 更新
- [x] **Task 3.3**: 确保 `_handleCheckpointTriggered` 与 `CheckpointPopover` 均使用应用内音量

### Phase 4: 全链路验收
- [x] **Task 4.1**: 运行 `flutter analyze` 确保 0 报错
- [x] **Task 4.2**: 运行 `flutter test` 全套测试
- [x] **Task 4.3**: 热重载并通知用户测试

---

## 3. 📂 文件变更清单

| 操作 | 文件路径 | 说明 |
| :--- | :--- | :--- |
| **新建** | `lib/ui/widgets/volume_setting_dialog.dart` | 5 级音量调节弹窗组件 |
| **修改** | `lib/models/timer_session.dart` | 补充 VolumeLevel 枚举与便捷转换方法 |
| **修改** | `lib/ui/screens/timer_screen.dart` | AppBar 集成音量调节入口 |
| **新建** | `test/ui/volume_setting_dialog_test.dart` | 5 级音量调节测试 |
| **新建** | `specs/features/03_in_app_volume_control.spec.md` | 功能规格书 |
| **新建** | `specs/plans/03_in_app_volume_control.plan.md` | 实施计划书 |
