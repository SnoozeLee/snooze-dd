# 节点触发文案与运行时间排序修复实施计划 (05_checkpoint_display_and_timeline_sorting.plan.md)

> **关联 Spec**：`specs/features/05_checkpoint_display_and_timeline_sorting.spec.md`  
> **实施负责人**：AI 架构助手 & 开发者  
> **当前状态**：Done  
> **启动时间**：2026-11-18  

---

## 1. 🎯 实施概览与交付标准 (Deliverable Summary)

- **本次迭代目标**：
  - 修复节点列表面板在 `elapsed` 触发类型下误显示为“剩余”的缺陷。
  - 重构节点列表排序算法为真实的**运行触发时序升序（Chronological Execution Order）**。
  - 完善添加节点弹窗，支持正计时（已进行至）与倒计时（剩余）两种模式。
- **质量门禁要求**：
  - [x] 编写对应的模型与组件单元测试
  - [x] Flutter 类型检查 0 报错 (`flutter analyze`)
  - [x] 现存全套测试回归通过 (`flutter test`)

---

## 2. 🪜 任务阶段划分与执行清单 (Phased Task Checklist)

### Phase 1: 契约与领域计算方法落地 (Foundation & Contracts)
- [x] **Task 1.1**: 在 `Checkpoint` 模型中新增 `getTriggerElapsedSeconds` 与 `formattedTriggerLabel` (`lib/models/checkpoint.dart`)
- [x] **Task 1.2**: 编写模型单元测试 (`test/models/checkpoint_test.dart` / `test/core/timer_engine_test.dart`)

### Phase 2: 界面渲染与排序升级 (UI & Sorting Logic)
- [x] **Task 2.1**: 更新 `CheckpointListSheet` (`lib/ui/widgets/checkpoint_list_sheet.dart`)：
  - 使用 `cp.formattedTriggerLabel` 替代硬编码的 "剩余"
  - 排序算法替换为 `a.getTriggerElapsedSeconds(totalDuration).compareTo(b.getTriggerElapsedSeconds(totalDuration))`
  - 优化添加节点弹窗，支持配置触发类型
- [x] **Task 2.2**: 编写 `CheckpointListSheet` 组件测试 (`test/ui/checkpoint_list_sheet_test.dart`)，覆盖文案与时序验证

### Phase 3: 质量验证与提交 (Verification & Commit)
- [x] **Task 3.1**: 运行 `flutter analyze` 与 `flutter test`
- [x] **Task 3.2**: 规范化 Git 原子提交
