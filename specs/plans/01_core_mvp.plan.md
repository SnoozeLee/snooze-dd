# SnoozeDD 核心 MVP 实施计划与任务分解 (Implementation Plan)

> **关联 Spec**：[specs/features/01_core_timer_announcement.spec.md](specs/features/01_core_timer_announcement.spec.md)  
> **实施负责人**：AI 编程助手 & 开发者  
> **技术栈**：Flutter (Dart)  
> **当前状态**：Ready to Start  
> **启动时间**：2026-11-17  

---

## 1. 🎯 实施概览与交付标准 (Deliverable Summary)

- **本次迭代目标**：交付 SnoozeDD 移动端 MVP，包含倒计时/正计时、多时间节点动态添加、自定义离线 TTS 语音播报及后台稳定运行。
- **质量门禁要求**：
  - [ ] 核心计时与调度算法 100% 单元测试覆盖并通过 (`flutter test`)
  - [ ] Dart 分析器 0 警告 0 报错 (`flutter analyze`)
  - [ ] 严格遵循原子化 Git 提交（每个 Phase 独立提交，严禁无关杂质与绝对路径）

---

## 2. 🪜 任务阶段划分与执行清单 (Phased Task Checklist)

### Phase 1: 工程初始化与核心依赖 (Foundation & Scaffolding)
- [ ] **Task 1.1**: 初始化 Flutter 移动端项目骨架 (`snooze_dd`)
  - **验证方式**: `flutter analyze` 无致命错误，工程结构清晰
- [ ] **Task 1.2**: 配置 `pubspec.yaml` 核心依赖：
  - `flutter_tts`: 离线文本转语音
  - `audioplayers`: 柔和轻提示音播放
  - `shared_preferences`: 本地轻量配置持久化
  - `uuid`: 节点唯一标识生成
- [ ] **Task 1.3**: 建立整洁的模块目录架构 (`lib/core`, `lib/models`, `lib/services`, `lib/ui`)

### Phase 2: 领域数据模型与纯 Dart 计时引擎 (Core Domain & Logic)
- [ ] **Task 2.1**: 定义核心实体类 `Checkpoint` 与 `TimerSession`
  - **验证方式**: 编写序列化与反序列化单测并通过
- [ ] **Task 2.2**: 编写核心计时器与多节点调度器（TDD 红绿灯模式）
  - 实现基于 `DateTime.now()` 差值校准的时钟脉冲，彻底防范后台休眠漂移
  - 实现中间节点触发去重与时间升序队列管理
  - **验证方式**: `flutter test test/core/timer_engine_test.dart` 全绿通过

### Phase 3: 语音播报与轻音效服务层 (Audio & TTS Engine)
- [ ] **Task 3.1**: 封装 `TtsService`：实现手机系统离线语音朗读与语速、音量参数适配
- [ ] **Task 3.2**: 封装 `ChimeAudioService`：预置柔和提示音（颂钵/风铃/水滴）资产
- [ ] **Task 3.3**: 编写语音播放防并发阻塞队列（Sequential Announcement Queue）

### Phase 4: 移动端用户界面与交互开发 (Mobile UI & Presentation)
- [ ] **Task 4.1**: 计时主表盘视图（直观的时间倒计显示与环形进度条）
- [ ] **Task 4.2**: 节点时间轴列表配置器（支持添加节点、调整触发时间、输入自定义播报文案）
- [ ] **Task 4.3**: 控制按键栏（开始、暂停、重置、屏幕常亮切换开关）

### Phase 5: 后台保活机制与全链路验收 (Background & Sign-off)
- [ ] **Task 5.1**: 配置 Android `AndroidManifest.xml` 前台服务权限与 iOS `Info.plist` 后台音频模式
- [ ] **Task 5.2**: 对照 Spec 中的 3 大 BDD 场景逐项执行联调与功能验收
- [ ] **Task 5.3**: 归档实施日志与阶段验收确认

---

## 3. 🔍 核心验证命令清单 (Verification Commands)

```bash
# 1. 静态代码分析与类型检查
flutter analyze

# 2. 执行核心算法单元测试
flutter test

# 3. 本地编译与运行调试
flutter run
```
