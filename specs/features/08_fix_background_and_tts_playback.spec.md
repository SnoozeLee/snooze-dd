# 缺陷修复规格书：息屏后台保活与 TTS 语音播报修复

> **缺陷编号**：#BUG-08  
> **关联功能**：核心计时器 (`01_core_timer_announcement.spec.md`)、音量控制 (`03_in_app_volume_control.spec.md`)  
> **严重等级**：P1 (核心功能异常)  
> **修复负责人**：Antigravity Agent  

---

## 1. 🐞 缺陷现象与复现路径

### 1.1 缺陷 1：息屏后无任何通知声音
- **现象描述**：
  在 Android (小米手机 HyperOS/MIUI) 上启动番茄钟倒计时后，一旦用户主动按电源键锁屏（息屏）或手机自动锁屏休眠，中间经过的检查点（Checkpoint）和倒计时完成时均**没有任何声音与提示**。只有再次按亮屏幕解锁进入 App 后，时间才被刷新，错过了提醒。
- **根因分析 (RCA)**：
  1. **Doze 模式与休眠冻结**：小米 MIUI/HyperOS 对后台应用有激进的省电休眠策略。应用息屏后，未持有 CPU WakeLock 且未启动系统前台服务（Foreground Service），系统在几秒内立即休眠 CPU 并冻结 Dart Isolate，`Timer.periodic` 定时器彻底挂起停跳。
  2. **缺少前台服务通知**：虽然 `AndroidManifest.xml` 中声明了 `FOREGROUND_SERVICE` 与 `WAKE_LOCK`，但项目中没有编写任何 Android 原生前台服务或保活代码。

### 1.2 缺陷 2：能听到铃声却听不见 TTS 文字播报（包含测试按钮）
- **现象描述**：
  在检查点到达或在设置中点击“测试”按钮时，能够听到轻柔铃声（wav 音效），但是后续的文字语音朗读**完全静音无声**。
- **根因分析 (RCA)**：
  1. **Android 11+ 软件包可见性限制 (Package Visibility)**：
     在 Android 11 (API 30)+ 上，系统默认对应用隔离已安装软件包。若未在 `AndroidManifest.xml` 的 `<queries>` 标签中显式声明 `<intent><action android:name="android.intent.action.TTS_SERVICE" /></intent></queries>`，应用将无法查询和绑定系统中的任何 TTS 引擎（如小米内置的 `com.xiaomi.mibrain.speech` 小爱语音合成或讯飞 TTS），导致 `FlutterTts` 原生实例化失败或连不上引擎。
  2. **语言编码兼容性与引擎容错缺失**：
     在国产定制系统上，系统默认 TTS 引擎可能将中文识别为 `zh`、`zh_CN`、`cmn-Hans-CN` 等，直接硬编码 `setLanguage("zh-CN")` 且未捕获错误或未做 fallback 会导致播报失败。
  3. **Android 端缺少 `awaitSpeakCompletion(true)`**：
     未设置语音播放完成等待，且在播报前连续调用 `stop()` 与 `speak()`，导致原生异步通道竞争被直接取消。
  4. **音频焦点与混音配置缺失**：
     原有代码仅对 iOS 配置了 `setIosAudioCategory`，Android 端未配置音频流类型（应走 `STREAM_MUSIC`），导致在铃声播放后与系统的音频焦点发生冲突。

---

## 2. 🎯 修复方案与边界 (Scope Boundaries)

### 2.1 In-Scope (本次修复必须覆盖)
1. **Manifest 修复**：
   - 在 `android/app/src/main/AndroidManifest.xml` 中声明 `android.intent.action.TTS_SERVICE`，解决 Android 11+ 软件包可见性封锁。
2. **TTS 健壮性增强 (`lib/services/tts_service.dart`)**：
   - 增加 Android 端 `awaitSpeakCompletion(true)` 设置。
   - 优化语言匹配机制：优先 `zh-CN`，兼容 `zh`、`zh_CN` 及系统默认中文引擎。
   - 去除连续并发 `stop()` 导致的竞争打断，加入防并发锁保护与音频焦点流（`STREAM_MUSIC`）适配。
3. **Android 原生前台服务与 WakeLock 保活**：
   - 原生端（Kotlin）实现 `TimerForegroundService`：常驻低干扰通知栏提醒（显示“专注中，剩余 mm:ss”），运行期间持有 `PARTIAL_WAKE_LOCK`。
   - 通过 `MethodChannel` 提供 Dart 侧接口：`startService`、`updateProgress`、`stopService`。
   - 在 `TimerScreen` 中与 `TimerEngine` 生命周期严格同步（启动时开启前台服务，暂停/重置/结束时停止前台服务并释放 WakeLock）。
4. **重新打出 Release 版 APK 供小米真机安装验证**。

### 2.2 Out-of-Scope (本次不做)
- 引入重量级第三方后台服务包（为保持最小体积，使用原生 Kotlin 实现极简前台保活服务）。
- 云端语音合成（坚持完全本地离线运行）。

---

## 3. 🧪 验证准则与质量门禁

1. **单测套件**：现有 32 个单测 + 新增服务状态与 TTS 降级测试全部通过（0 failure）。
2. **TTS 本地发声验证**：点击测试按钮，铃声响后能够正常听到普通话语音朗读。
3. **息屏计时验证**：启动专注后锁屏，倒计时在后台准时推进，到达指定节点时响铃并播报，倒计时结束时正常提示。
4. **代码静态检查**：`flutter analyze` 0 error。
