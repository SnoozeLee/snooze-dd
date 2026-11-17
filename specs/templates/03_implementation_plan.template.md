# [功能/模块名称] 任务拆解与实施计划 (Implementation Plan)

> **关联 Spec**：`[链接至 specs/features/xxx_spec.md]`  
> **实施负责人**：[开发者/AI Agent]  
> **当前状态**：Not Started | In Progress | Ready for Review | Done  
> **启动时间**：YYYY-MM-DD  

---

## 1. 🎯 实施概览与交付标准 (Deliverable Summary)

- **本次迭代目标**：[简要说明本次计划产出的代码或特性范围]
- **质量门禁要求**：
  - [ ] 所有新增代码需包含对应的单元测试，覆盖率目标 ≥ 80%
  - [ ] TypeScript 类型检查 0 报错 (`npm run type-check`)
  - [ ] 代码风格与 Linter 检查通过 (`npm run lint`)
  - [ ] 现存测试套件全部回归通过 (`npm test`)

---

## 2. 🪜 任务阶段划分与执行清单 (Phased Task Checklist)

> [!TIP]
> 推荐遵循 **TDD / 红-绿-重构** 循环，每个任务保持原子性，可独立提交与验证。

### Phase 1: 准备工作与数据契约定义 (Foundation & Contracts)
- [ ] **Task 1.1**: 声明/更新核心类型与接口定义 (`src/types/...`)
  - **验证方式**: 执行类型检查无报错
- [ ] **Task 1.2**: 数据库迁移脚本或 Schema 更新 (`prisma/schema.prisma` 或 SQL)
  - **验证方式**: 执行本地迁移生成工具，确保库表结构正确创建
- [ ] **Task 1.3**: 补齐 Mock 数据或测试 Fixtures

### Phase 2: 核心业务逻辑与领域服务 (Core Business & Logic)
- [ ] **Task 2.1**: 编写核心服务单元测试用例（红灯状态）
  - **用例覆盖**: 正常计算逻辑、边界条件、异常抛错
- [ ] **Task 2.2**: 实现核心服务业务逻辑 (`src/services/...`)
  - **验证方式**: 运行单元测试变绿通过
- [ ] **Task 2.3**: 重构代码结构，优化可读性与性能

### Phase 3: API 路由与对外接口实现 (API & Controller Layer)
- [ ] **Task 3.1**: 编写 Request DTO 参数校验 Schema (`zod` / `joi`)
- [ ] **Task 3.2**: 实现 Controller / Route Handler
- [ ] **Task 3.3**: 编写 API 集成测试 (`supertest` / 内部 API 测试工具)
  - **验证方式**: 模拟 HTTP 请求校验状态码与返回体

### Phase 4: 前端交互与界面渲染 (UI & Presentation - 若适用)
- [ ] **Task 4.1**: 封装 API 请求客户端函数
- [ ] **Task 4.2**: 实现组件视图与交互逻辑 (`src/components/...`)
- [ ] **Task 4.3**: 完善加载态 (Loading)、空状态 (Empty) 与错误提示 (Error Handling)

### Phase 5: 全链路验收与上线检查 (Verification & Sign-off)
- [ ] **Task 5.1**: 按照 Spec 中的 BDD 场景逐项执行人工/E2E验收
- [ ] **Task 5.2**: 检查无 console.log 散落与敏感信息泄漏
- [ ] **Task 5.3**: 更新相关技术文档与 README

---

## 3. 🔍 验证命令清单 (Verification Commands)

```bash
# 1. 类型检查
npm run typecheck

# 2. 代码风格格式化检查
npm run lint

# 3. 运行受影响模块的单元测试
npm test -- path/to/spec.test.ts

# 4. 全量回归测试
npm test
```

---

## 4. 📝 变更记录与阻碍追踪 (Blockers & Progress Log)

| 日期 | 进展说明 | 遇到的阻碍与解决方案 | 状态 |
| :--- | :--- | :--- | :--- |
| YYYY-MM-DD | 完成 Phase 1 契约定义与数据迁移 | 无阻碍 | Done |
| YYYY-MM-DD | 核心业务测试编写完成 | 某第三方 API 响应不稳定，暂用 Mock 解决 | In Progress |
