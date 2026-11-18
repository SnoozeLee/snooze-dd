# 实施计划：节点设置基准选择器与文案联动优化 (09)

> **关联规格**：[specs/features/09_fix_checkpoint_selector_and_text_sync.spec.md](../features/09_fix_checkpoint_selector_and_text_sync.spec.md)  
> **负责人**：Antigravity Agent  
> **状态**：已完成  

---

## 📋 阶段拆解 (Phased Execution)

### Phase 1: 触发基准类型 SegmentedButton 重构
- [x] 1.1 调整 segments 顺序：左侧为“正计进行”（`elapsed`，`timer_outlined` 图标），右侧为“倒计剩余”（`remaining`，`hourglass_top` 图标）。
- [x] 1.2 设置 `showSelectedIcon: false`，防止选中时将图标替换为对勾。

### Phase 2: 播报文案联动逻辑实现
- [x] 2.1 实现中文数字转换 `_numberToChinese(int n)` 与默认文案生成函数 `_generateDefaultText(int minutes, CheckpointTriggerType type)`。
- [x] 2.2 引入 `_isTextManuallyEdited` 状态跟踪用户是否主动编辑。
- [x] 2.3 在 `TextField` 监听 `onChanged`，正确维护手动编辑状态。
- [x] 2.4 在时间更改（下拉选择）与基准类型切换时，若未手动编辑，自动更新 `_textController.text`。

### Phase 3: 单元测试覆盖与验证
- [x] 3.1 在 `test/ui/checkpoint_popover_test.dart` 补充文案时间联动及未编辑判断的 widget 测试。
- [x] 3.2 运行全量 `flutter test` 与 `flutter analyze` 确保 0 warning / 0 error（36/36 passed）。
- [x] 3.3 重新构建 Release APK (`dist/app-release-arm64.apk`)。
