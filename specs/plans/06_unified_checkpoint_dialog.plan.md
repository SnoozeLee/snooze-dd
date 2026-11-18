# 统一播报节点弹窗实施计划 (06_unified_checkpoint_dialog.plan.md)

> **关联 Spec**：`specs/features/06_unified_checkpoint_dialog.spec.md`  
> **实施负责人**：AI 架构助手 & 开发者  
> **当前状态**：Done  
> **启动时间**：2026-11-18  

---

## 1. 🎯 实施概览与交付标准 (Deliverable Summary)

- **本次迭代目标**：
  - 重构 `lib/ui/widgets/checkpoint_popover.dart`，支持添加模式（`checkpoint == null`）与编辑模式（`checkpoint != null`）。
  - 全面使用 `SegmentedButton` 倒计剩余/正计进行样式。
  - 重构 `CheckpointListSheet`，移除内部冗余私有 dialog，改用统一的 `CheckpointPopover.show`。
- **质量门禁要求**：
  - [x] 补齐添加与编辑模式下的组件测试
  - [x] Flutter 类型检查 0 报错 (`flutter analyze`)
  - [x] 现存测试全部通过 (`flutter test`)

---

## 2. 🪜 任务阶段划分与执行清单 (Phased Task Checklist)

### Phase 1: 重构 `CheckpointPopover` 成为统一样式组件
- [x] **Task 1.1**: 更新 `CheckpointPopover` 支持可选 `checkpoint` 参数，在 Add 与 Edit 状态间自适应。
- [x] **Task 1.2**: 替换原下拉切换为 `SegmentedButton`【倒计剩余】/【正计进行】。

### Phase 2: 清理 `CheckpointListSheet` 冗余代码
- [x] **Task 2.1**: 将 `_showAddDialog` 调用替换为统一的 `CheckpointPopover.show`。

### Phase 3: 自动化测试与质量验收
- [x] **Task 3.1**: 更新 `test/ui/checkpoint_popover_test.dart` 覆盖添加与编辑模式。
- [x] **Task 3.2**: 运行 `flutter analyze` 与 `flutter test`。
- [x] **Task 3.3**: 规范化 Git 原子提交。
