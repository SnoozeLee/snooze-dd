# 🤖 AI 编程助手协作规范 (AGENTS.md)

本仓库采用 **规格驱动开发 (Spec-Driven Development, SDD)** 模式。所有参与本项目的 AI 编码助手（包括 Google Antigravity、Claude Code、Cursor 等）及开发者，均需严格遵守以下协作准则。

---

## 🎯 核心开发守则 (Golden Rules)

1. **Spec-First 原则**：
   - 严禁在未经规格对齐的情况下直接跳入复杂业务代码编写（禁止无拘束的 Blind Vibe Coding）。
   - 开发任何重大新功能前，先在 `specs/features/` 编写或确认对应的 Spec 规格书。
2. **显式声明边界 (Scope Boundaries)**：
   - 必须严格遵守对应 Spec 中的 `In-Scope` 与 `Out-of-Scope` 边界。
   - 不得擅自引入未经商榷的额外第三方重型依赖。
3. **消除歧义，杜绝猜测**：
   - 遇到未说明的技术细节或业务逻辑分歧时，使用 `[NEEDS CLARIFICATION]` 及时向开发者提问确认，严禁盲目臆测。
4. **小步推进与自动化验证**：
   - 在 `specs/plans/` 拆解分步实施计划，按 Phase 原子化推进。
   - 遵循红-绿-重构循环，优先编写测试与类型契约，确保交付代码 0 类型报错、0 单测退化。

---

## 📂 规格文件规范 (Specification Hierarchy)

- **功能规格模板**：[01_feature_spec.template.md](file:///k:/Antigravity-workspaces/SnoozeDD/specs/templates/01_feature_spec.template.md)
- **技术架构模板**：[02_technical_design.template.md](file:///k:/Antigravity-workspaces/SnoozeDD/specs/templates/02_technical_design.template.md)
- **任务拆解模板**：[03_implementation_plan.template.md](file:///k:/Antigravity-workspaces/SnoozeDD/specs/templates/03_implementation_plan.template.md)
- **缺陷修复模板**：[04_bug_fix_spec.template.md](file:///k:/Antigravity-workspaces/SnoozeDD/specs/templates/04_bug_fix_spec.template.md)
- **规格中心指引**：[specs/README.md](file:///k:/Antigravity-workspaces/SnoozeDD/specs/README.md)

---

## 🛠 代码产出与质量门禁 (Quality Gateways)

提交任何代码变更前，必须运行并通过以下指令：
1. **类型检查**：无任何类型推断或语法报错。
2. **代码风格与 Linter**：符合项目 ESLint / Prettier 规范。
3. **单元与集成测试**：覆盖新增功能路径及异常边缘场景。
