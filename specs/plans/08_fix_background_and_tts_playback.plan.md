# 实施计划：息屏后台保活与 TTS 语音播报修复 (08)

> **关联规格**：[specs/features/08_fix_background_and_tts_playback.spec.md](../features/08_fix_background_and_tts_playback.spec.md)  
> **负责人**：Antigravity Agent  
> **状态**：已完成  

---

## 📋 阶段拆解 (Phased Execution)

### Phase 1: TTS 引擎访问与播报逻辑重构
- [x] 1.1 在 `android/app/src/main/AndroidManifest.xml` 中添加 `<queries><intent><action android:name="android.intent.action.TTS_SERVICE" /></intent></queries>`。
- [x] 1.2 在 `lib/services/tts_service.dart` 增强：
  - 初始化支持 `awaitSpeakCompletion(true)`。
  - 动态检测并支持语言降级（`zh-CN` -> `zh` -> `zh_CN` -> 系统默认）。
  - 避免 `stop()` 异步竞态，重构安全防并发队列。
- [x] 1.3 在 `lib/services/audio_chime_service.dart` 与 `TtsService` 之间确认音频流（使用 Music 音频流与混音闪避，避免被独占静音）。

### Phase 2: Android 原生前台服务与 WakeLock 保活
- [x] 2.1 在 `android/app/src/main/kotlin/com/snoozedd/snooze_dd/` 创建 `TimerForegroundService.kt`：
  - 创建常驻通知渠道 `snoozedd_timer_channel`（Importance: LOW，不发出侵入性蜂鸣，但持续保活）。
  - 获取与释放 `PowerManager.PARTIAL_WAKE_LOCK`。
  - 支持 `ACTION_START`、`ACTION_UPDATE`、`ACTION_STOP`。
- [x] 2.2 在 `android/app/src/main/AndroidManifest.xml` 中注册 `TimerForegroundService` 服务组件并补充 `POST_NOTIFICATIONS` 权限。
- [x] 2.3 在 `MainActivity.kt` 中注册 Flutter `MethodChannel("com.snoozedd.snooze_dd/background_service")`。
- [x] 2.4 在 Dart 侧封装 `lib/services/background_service.dart`。

### Phase 3: UI 计时生命周期同步与前台联动
- [x] 3.1 在 `lib/ui/screens/timer_screen.dart` 中，将 `TimerEngine` 的 `start`、`pause`、`reset`、`complete` 与 `BackgroundService` 严格绑定：
  - 开始计时：启动前台服务，持有 WakeLock。
  - 倒计时进行中：周期性同步剩余时间到通知栏。
  - 暂停/停止/完成：关闭前台服务并释放 WakeLock。
- [x] 3.2 在测试按钮与 Checkpoint 触发处确保延迟播放时序合理（800ms 平滑交接）。

### Phase 4: 质量门禁与打包发布
- [x] 4.1 运行 `flutter analyze` 确保 0 warning / 0 error。
- [x] 4.2 运行 `flutter test` 确保已有 32 个测试和新增测试全部通过（35/35 passed）。
- [x] 4.3 重新构建单架构精简版 APK：`dist/app-release-arm64.apk`。
