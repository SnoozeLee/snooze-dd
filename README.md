# SnoozeDD (声动番茄钟)

SnoozeDD 是一款专注于心流体验与节点语音提醒的极简高级感计时工具，采用 **规格驱动开发 (Spec-Driven Development, SDD)** 架构构建。

---

## 🛠️ 构建与运行指南 (Build & Run Guide)

### 1. 环境准备 (Prerequisites)
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (建议版本 ≥ 3.19.0)
- **Windows 桌面端构建要求**：安装了 "C++ 桌面开发" 工作负载的 Visual Studio 2022
- **Web 端运行要求**：Google Chrome 或现代标准浏览器

获取项目依赖：
```bash
flutter pub get
```

---

### 2. 本地开发与调试 (Development & Run)

- **在浏览器中运行 (Web 调试)**：
  ```bash
  # 启动 Chrome 调试
  flutter run -d chrome

  # 或启动本地 Web 服务 (指定端口)
  flutter run -d web-server --web-port=8080 --web-hostname=127.0.0.1
  ```

- **在 Windows 桌面运行**：
  ```bash
  flutter run -d windows
  ```

---

### 3. 正式发布打包 (Production Build)

#### 🖥️ Windows 桌面独立安装包 (x64 Release)
运行以下命令构建 Release 版本可执行程序：
```bash
flutter build windows --release
```
- **编译产物路径**：`build/windows/x64/runner/Release/`
- **打包为绿色版 Zip 压缩包 (PowerShell)**：
  ```powershell
  # 创建 dist 目录并打包 Release 产物
  New-Item -ItemType Directory -Force -Path dist
  Compress-Archive -Path build\windows\x64\runner\Release\* -DestinationPath dist\SnoozeDD-Windows-x64.zip -Force
  ```
  打包后可将 `dist/SnoozeDD-Windows-x64.zip` 直接解压在任意 Windows 电脑运行 `snooze_dd.exe`。

#### 🌐 Web 静态站点构建
运行以下命令构建纯前端 Web 应用：
```bash
flutter build web --release
```
- **产物路径**：`build/web/`
- 可直接部署至 GitHub Pages、Cloudflare Pages、Nginx 或任何静态网页托管服务器。

---

### 4. 自动化测试与质量门禁 (Quality Gateways)

每次提交代码前需确保以下检查全部通过：

```bash
# 1. 代码静态分析与规范检查 (要求 0 警告、0 错误)
flutter analyze

# 2. 运行完整单元与组件测试套件
flutter test
```

---

## ✨ 核心特性一览

- ⏱️ **环形专注表盘**：高对比、圆润饱满的进度圆弧（`FontWeight.w800` 等宽粗体大字，远距离一目了然）。
- 🔔 **多阶段节点提醒**：支持剩余时间/过去时间两种触发方式，节点配置面板内可直接点击重新设置时长并试听声音。
- 🔊 **应用内独立 5 级音量**：从静音至高亢，完全独立于操作系统主音量，平衡与其他软件的声音输出。
- 🗣️ **离线伴音与 TTS 朗读**：支持清脆风铃、禅意颂钵、清澈水滴等纯净 PCM 音频与语音协同播报。
- 🎨 **双高级感配色 × 双主题模式 (100% 拒绝渐变)**：
  - 【岩茶金石】(禅意温润，熟焦茶与琥珀暖金)
  - 【松烟墨青】(理性克制，冷杉板岩与清透翡翠)
  - 纯色背景微质感纹理（和纸砂石微粒 / 精密打孔点阵 / 纯净平面）
  - 100% 纯矢量几何图标（绝无系统 Emoji 字符）。

---

## 📂 规格驱动开发 (Spec Hierarchy)

- 🤖 **AI 协作规范**：[AGENTS.md](AGENTS.md)
- 📐 **Spec 规格中心**：[specs/README.md](specs/README.md)
  - 功能规格模板：[01_feature_spec.template.md](specs/templates/01_feature_spec.template.md)
  - 架构设计模板：[02_technical_design.template.md](specs/templates/02_technical_design.template.md)
  - 实施计划模板：[03_implementation_plan.template.md](specs/templates/03_implementation_plan.template.md)
  - 缺陷修复模板：[04_bug_fix_spec.template.md](specs/templates/04_bug_fix_spec.template.md)
- 📋 **已落地功能规格书**：
  - [01_multi_checkpoint_announcement.spec.md](specs/features/01_multi_checkpoint_announcement.spec.md)
  - [02_custom_duration_and_dial_checkpoints.spec.md](specs/features/02_custom_duration_and_dial_checkpoints.spec.md)
  - [03_discrete_volume_control.spec.md](specs/features/03_discrete_volume_control.spec.md)
  - [04_theme_color_design.spec.md](specs/features/04_theme_color_design.spec.md)
