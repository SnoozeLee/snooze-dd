# 节点触发文案与运行时间排序缺陷修复规格书 (Bug Fix Spec)

> **缺陷编号**：BUG-05  
> **发现日期**：2026-11-18  
> **严重等级**：P2 (一般功能与体验缺陷)  
> **修复负责人**：AI 架构助手 & 开发者  
> **状态**：Resolved (已修复并通过回归测试)  

---

## 1. 🐞 缺陷现象与复现路径 (Bug Summary & Reproduction)

### 1.1 现象描述
1. **文案显示错误**：当用户为节点配置为“已进行至”正向计时触发时（`triggerType: elapsed`），在“播报节点设置”弹窗面板（`CheckpointListSheet`）中，对应列表项下方的时间副标题依然被无差别硬编码显示为 `剩余 XX 分钟`。
2. **列表排序错乱**：节点列表的排序逻辑硬编码为 `b.offsetSeconds.compareTo(a.offsetSeconds)`，导致“正计时进行节点”与“倒计时剩余节点”混合时，顺序发生混乱颠倒，未能按照真实的运行触发时序（Timeline Order）排列。

### 1.2 复现步骤
1. 打开应用，进入 25 分钟番茄钟会话。
2. 打开“配置提醒节点”弹窗，点击任一节点进行编辑。
3. 切换触发类型为“进行至 5 分钟”，保存。
4. 返回节点列表，发现列表显示“剩余 5 分钟”，且节点排列在列表后方而非首位。

---

## 2. 🔬 根因深度剖析 (Root Cause Analysis - RCA)

1. **展示文案硬编码**：
   `lib/ui/widgets/checkpoint_list_sheet.dart` 中，格式化时间标签时仅做了 `mins` 和 `secs` 计算，直接拼接 `'剩余 $mins 分钟'`，未判断 `cp.triggerType == CheckpointTriggerType.elapsed`。
2. **排序维度缺失**：
   排序直接以 `offsetSeconds` 倒序排序，这只适用于所有节点都是 `remaining` 的情况。当引入 `elapsed` 节点后，`offsetSeconds` 代表的是“从开始计起的秒数”而非“剩余秒数”。必须将所有节点统一转换为“距离计时开始的运行时间（Elapsed Time）”来执行升序排序。

---

## 3. 🛠 修复方案设计与规范 (Proposed Fix)

### 3.1 模型层增加标准化方法 (`lib/models/checkpoint.dart`)
1. **`getTriggerElapsedSeconds(int totalDurationSeconds)`**：
   - 当 `triggerType == CheckpointTriggerType.elapsed` 时，返回 `offsetSeconds`；
   - 当 `triggerType == CheckpointTriggerType.remaining` 时，返回 `(totalDurationSeconds - offsetSeconds).clamp(0, totalDurationSeconds)`。
2. **`formattedTriggerLabel` 属性**：
   - 当 `triggerType == CheckpointTriggerType.elapsed` 时，格式化为 `已进行至 $mins 分钟`（若含秒则 `已进行至 $mins 分 $secs 秒`）；
   - 当 `triggerType == CheckpointTriggerType.remaining` 时，格式化为 `剩余 $mins 分钟`（若含秒则 `剩余 $mins 分 $secs 秒`）。

### 3.2 节点列表面板升级 (`lib/ui/widgets/checkpoint_list_sheet.dart`)
1. 列表初始化及每次节点增改时，统一调用 `_sortList()`：
   ```dart
   _list.sort((a, b) => a.getTriggerElapsedSeconds(widget.totalDurationSeconds)
       .compareTo(b.getTriggerElapsedSeconds(widget.totalDurationSeconds)));
   ```
   使列表从上到下严格对应计时器从 0 秒到终点的先后运行触发顺序。
2. 列表项副标题直接绑定 `cp.formattedTriggerLabel`。
3. 添加节点弹窗增加“触发方式”切换（剩余时间 vs 已进行至）。

---

## 4. 🧪 自动化测试验证矩阵 (Test Matrix)

1. **单元测试 (`test/models/checkpoint_test.dart`)**：
   - 验证 `formattedTriggerLabel` 在 `remaining` 和 `elapsed` 下分别输出 `剩余 X 分钟` 和 `已进行至 X 分钟`。
   - 验证 `getTriggerElapsedSeconds` 在 25 分钟（1500秒）总时长下的准确换算。
2. **组件测试 (`test/ui/checkpoint_list_sheet_test.dart`)**：
   - 验证包含 `elapsed(5m)`、`remaining(10m)`、`remaining(5m)` 的列表按照运行时间正确升序排列（5m -> 15m -> 20m）。
   - 验证界面渲染出 `已进行至 5 分钟` 标签。
