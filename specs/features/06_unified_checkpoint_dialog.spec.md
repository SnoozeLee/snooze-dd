# 统一播报节点添加与编辑弹窗规格书 (Unified Checkpoint Dialog Spec)

> **功能编号**：FEAT-06  
> **创建日期**：2026-11-18  
> **状态**：Approved  
> **负责人**：AI 架构助手 & 开发者  

---

## 1. 🎯 需求背景与设计目标

### 1.1 背景
当前代码中存在两个独立的节点弹窗：
1. `CheckpointListSheet` 内部的私有 `_showAddDialog`（负责添加节点，拥有良好的 `SegmentedButton` 倒计/正计选择样式）。
2. 独立的 `CheckpointPopover`（负责编辑已有节点，之前采用分列下拉框，样式与交互不统一）。

### 1.2 目标
- 将“添加节点”与“设置/编辑节点”弹窗**统一合并为一个高复用组件** `CheckpointPopover`。
- **保留并统一采用**原添加节点面板的 `SegmentedButton`【倒计剩余】/【正计进行】按钮样式。
- 无论是在表盘点击节点、在列表中点击节点编辑，还是点击右上角添加新节点，均唤起同一组件，呈现完全一致的交互体验、色彩规范与声音试听功能。

---

## 2. 🧱 组件设计契约 (`CheckpointPopover`)

### 2.1 属性与静态调用入口
```dart
static Future<void> show(
  BuildContext context, {
  Checkpoint? checkpoint, // 为 null 时表示“添加模式”，非 null 表示“编辑模式”
  required int totalDurationSeconds,
  double volume = 0.8,
  ValueChanged<Checkpoint>? onSaved,
  ValueChanged<Checkpoint>? onUpdated, // 兼容别名
  VoidCallback? onDeleted,
})
```

### 2.2 两种模式的差异表现
| 元素 | 添加模式 (`checkpoint == null`) | 编辑模式 (`checkpoint != null`) |
| :--- | :--- | :--- |
| **顶栏标题** | `添加播报节点` | `节点设置` + 实时格式化时间副标题 |
| **启用开关** | 默认启用（不显示 Switch，简化初次录入） | 显示 `Switch` 开关，支持快速启闭节点 |
| **主操作按钮** | `添加` | `保存` |
| **删除操作** | 无删除按钮 | 左下角提供带二次确认的红色删除按钮 |

### 2.3 共享交互元素
1. **触发类型切换**：采用 `SegmentedButton`：
   - `CheckpointTriggerType.remaining`（倒计剩余，`Icons.timer_outlined`）
   - `CheckpointTriggerType.elapsed`（正计进行，`Icons.hourglass_top`）
2. **触发分钟数下拉选择**：根据当前类型动态展示 `剩余 $m 分钟` 或 `进行至 $m 分钟`。
3. **语音播报文案输入**：支持多行文字输入与占位提示。
4. **伴随提示音选择**：风铃、水滴、颂钵、无提示音。
5. **试听按钮**：支持一键播放提示音与 TTS 朗读试听。
