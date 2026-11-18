# 功能与缺陷优化规格书：节点设置触发基准选择器与文案联动优化

> **规格编号**：#SPEC-09  
> **关联模块**：节点配置弹窗 (`lib/ui/widgets/checkpoint_popover.dart`)  
> **优先级**：P2 (UI与交互体验优化)  
> **负责人**：Antigravity Agent  

---

## 1. 🎯 需求背景与痛点

1. **触发基准 Selector 图标与顺序问题**：
   - 之前在 `CheckpointPopover` 中，SegmentedButton 的排列是“倒计剩余”在左、“正计进行”在右。
   - 图标配置上，“正计进行”配置了沙漏（`hourglass_top`），“倒计剩余”配置了表（`timer_outlined`），存在逻辑错配。同时 Material 3 默认开启了 `showSelectedIcon: true`，在选中时将专属图标覆盖替换为对勾 `✓`，造成视觉混乱。
   - 用户明确诉求：**正计进行在左边，倒计剩余在右边**；正计进行使用表/计时器图标，倒计剩余使用沙漏图标；并且关闭选中的对勾覆盖（保持图标常驻）。
2. **触发时间与文案未联动问题**：
   - 在用户尚未手动编辑修改播报文案时，调节时间（例如从 5 分钟或 10 分钟调到 3 分钟），播报文案仍然停留在原文本（如“还有五分钟”或“还有十分钟”）。
   - 用户明确诉求：**在播报文案尚未被手动编辑前，修改触发时间或切换正/倒计模式时，文案应自动更新为对应数字的默认文案**（如选 3 分钟自动更新为“还有3分钟”或“还有三分钟”；选正计时则自动更新为“已经进行3分钟”）。如果用户已经手动编辑过文案，则尊重用户的自定义输入，不再自动覆盖。

---

## 2. 🛠 规格设计与交互定义

### 2.1 触发基准选择器 (SegmentedButton)
- **左右布局**：
  - 左项 (索引 0)：`value: CheckpointTriggerType.elapsed`，文案：`正计进行`，图标：`Icons.timer_outlined`
  - 右项 (索引 1)：`value: CheckpointTriggerType.remaining`，文案：`倒计剩余`，图标：`Icons.hourglass_top`
- **图标行为**：
  - 显式配置 `showSelectedIcon: false`，使得选中与未选中状态下均展示对应图标，避免被 `✓` 覆盖。

### 2.2 播报文案自动联动机制
- **默认文案生成函数**：
  - 输入：分钟数 `minutes`，触发类型 `type`
  - 若 `type == CheckpointTriggerType.remaining`：返回 `还有${_numberToChinese(minutes)}分钟`
  - 若 `type == CheckpointTriggerType.elapsed`：返回 `已经进行${_numberToChinese(minutes)}分钟`
  - 其中 `_numberToChinese(n)` 支持常用数字转汉字（如 1->一, 2->两, 3->三... 10->十, 15->十五, 25->二十五），并向下兼容阿拉伯数字朗读。
- **手动编辑感知标志 (`_isTextManuallyEdited`)**：
  - 初始化：
    - 新增模式下默认为 `false`。
    - 编辑模式下：若当前检查点的文案严格等于其当前时间生成的默认文案，则为 `false`；否则若包含用户自填文案，则为 `true`。
  - 用户在 `TextField` 输入时：
    - `onChanged` 触发时，若输入内容不等于当前时间对应默认文本且非空，置 `_isTextManuallyEdited = true`。
    - 若用户将输入清空或重新输回当前默认文本，恢复 `_isTextManuallyEdited = false`。
  - 触发条件：
    - 当用户改变触发分钟数（下拉选择）时，若 `!_isTextManuallyEdited`，自动执行 `_textController.text = _generateDefaultText(_offsetMinutes, _triggerType)`。
    - 当用户切换正/倒计类型时，若 `!_isTextManuallyEdited`，同样自动同步新类型与分钟数的默认文案。

---

## 3. 🧪 验收与测试标准

1. **Selector 呈现**：
   - 打开新增或编辑节点，左侧为带时钟图标的“正计进行”，右侧为带沙漏图标的“倒计剩余”。
   - 切换选中时，高亮选中项，不出现多余的对勾替换。
2. **文案自动联动**：
   - 新增节点时，默认 5 分钟，文案为“还有五分钟”。
   - 将下拉框切换到 3 分钟，文案立即变为“还有三分钟”。
   - 切换到“正计进行”，文案立即变为“已经进行三分钟”。
   - 用户手动将文案改为“去喝一口水”，再将时间从 3 分钟调到 8 分钟，文案依然保持“去喝一口水”不被覆盖。
3. **单元测试与回归**：
   - 编写自动化 Widget 测试验证上述联动。
   - 全量测试通过，重新打出 APK。
