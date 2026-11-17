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
5. **规范化 Git 提交 (Atomic & Disciplined Git Commits)**：
   - 每个特性的代码提交必须严格对齐其 Spec 及对应的 Phase 任务边界。
   - **杜绝无关文件**：提交前必须核对暂存区，严禁夹带未关联的临时文件、构建产物、调试断点或无关配置。
   - **杜绝漏提文件**：必须保证该特性涉及的所有必要文件（类型契约、核心实现、单测、Spec更新等）一次性完整原子提交。
6. **严禁包含绝对路径 (Strictly Relative Paths Only)**：
   - 项目内所有 Markdown 文档、超链接、代码与注释中，**绝对禁止**出现任何本地主机的绝对盘符路径（如 `C:\...`、`K:\...` 或 `file:///...`）。
   - 一律统一使用相对于项目根目录的相对路径（如 `specs/...`、`src/...`），严格防范本地文件系统拓扑泄漏。

---

## 📂 规格文件规范 (Specification Hierarchy)

- **功能规格模板**：[01_feature_spec.template.md](specs/templates/01_feature_spec.template.md)
- **技术架构模板**：[02_technical_design.template.md](specs/templates/02_technical_design.template.md)
- **任务拆解模板**：[03_implementation_plan.template.md](specs/templates/03_implementation_plan.template.md)
- **缺陷修复模板**：[04_bug_fix_spec.template.md](specs/templates/04_bug_fix_spec.template.md)
- **规格中心指引**：[specs/README.md](specs/README.md)

---

## 🛠 代码产出与质量门禁 (Quality Gateways)

提交任何代码变更前，必须运行并通过以下指令：
1. **类型检查**：无任何类型推断或语法报错。
2. **代码风格与 Linter**：符合项目 ESLint / Prettier 规范。
3. **单元与集成测试**：覆盖新增功能路径及异常边缘场景。

---

## 📦 Git 版本管理与提交规范 (Git Commit Standards)

所有由 AI 或人工执行的 Git 提交均须遵守以下规范：

### 1. 原子化与范围对齐 (Scope Alignment)
- **一事一提 (One Concern Per Commit)**：每一次 Commit 应只服务于单个明确的特性、修复或重构目标，严禁将多个不相干的需求打包混合提交。
- **与 Spec 阶段呼应**：特性开发期间，建议按实施计划的 Phase（如 `Phase 1: Contracts` -> `Phase 2: Core Logic` -> `Phase 3: UI`）小步提交。

### 2. 提交审查红线 (Inspection Gate)
每次执行 `git add` 与 `git commit` 前，必须通过 `git status` 与 `git diff --cached` 仔细审查：
- ❌ **严禁提交无关文件**：
  - 本地运行日志、临时测试脚本、临时缓存。
  - 编辑器私有配置（如 `.vscode/` 下除标准共享外的个人配置）。
  - 未经请求引入的第三方依赖修改。
- ❌ **严禁缺漏关键文件**：
  - 核心逻辑改动后，漏提对应的类型定义 (`.d.ts` / `types.ts`)。
  - 业务代码提交后，漏提配套的单元测试 (`*.test.ts` / `*.spec.ts`)。
  - 实施完成或阶段性推进后，漏提对应计划文档的进度勾选 (`specs/plans/*.plan.md`)。

### 3. 提交信息格式 (Conventional Commits)
统一采用语义化提交信息：
```text
<type>(<scope>): <清晰简洁的中文或英文摘要>

[可选的详细说明：阐述改动的动机以及主要变更点]
[可选的关联文档或Issue：如 Closes #12, Specs: specs/features/xxx.spec.md]
```

- **常用 Type 定义**：
  - `feat`: 新增特性或功能模块
  - `fix`: 修复缺陷或 Bug
  - `docs`: 文档变更（包括 Spec、Plan、README 等）
  - `refactor`: 代码重构（不改变现有外部行为及功能）
  - `test`: 新增或修改测试用例
  - `style`: 代码格式、空格、分号等非逻辑改动
  - `chore`: 构建配置、依赖维护、辅助工具变动
