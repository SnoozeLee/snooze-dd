import 'dart:async';
import '../models/checkpoint.dart';
import '../models/timer_session.dart';

/// 计时器状态通知回调定义
typedef OnTimerTick = void Function(int remainingSeconds, int elapsedSeconds);
typedef OnCheckpointTriggered = void Function(Checkpoint checkpoint);
typedef OnTimerStatusChanged = void Function(TimerStatus status);

/// 基于真实时间戳差值 (Delta-Time Calculation) 校准的高精度计时引擎
///
/// 具备抵御移动端锁屏休眠、后台冻结导致的定时器漂移能力。
class TimerEngine {
  TimerSession session;
  TimerStatus _status = TimerStatus.idle;

  Timer? _tickerTimer;
  DateTime? _referenceTime;
  int _baseElapsedSeconds = 0;
  int _currentElapsedSeconds = 0;

  final Set<String> _triggeredCheckpointIds = {};

  OnTimerTick? onTick;
  OnCheckpointTriggered? onCheckpointTriggered;
  OnTimerStatusChanged? onStatusChanged;
  void Function()? onCompleted;

  TimerEngine({
    required this.session,
    this.onTick,
    this.onCheckpointTriggered,
    this.onStatusChanged,
    this.onCompleted,
  });

  // --- Getters ---
  TimerStatus get status => _status;
  int get elapsedSeconds => _currentElapsedSeconds;
  int get remainingSeconds {
    if (session.mode == TimerMode.stopwatch) {
      return 0;
    }
    final remaining = session.totalDurationSeconds - _currentElapsedSeconds;
    return remaining > 0 ? remaining : 0;
  }

  double get progress {
    if (session.totalDurationSeconds <= 0) return 0.0;
    final p = _currentElapsedSeconds / session.totalDurationSeconds;
    return p.clamp(0.0, 1.0);
  }

  bool get isRunning => _status == TimerStatus.running;
  bool get isPaused => _status == TimerStatus.paused;
  bool get isIdle => _status == TimerStatus.idle;
  bool get isCompleted => _status == TimerStatus.completed;

  Set<String> get triggeredCheckpointIds =>
      Set.unmodifiable(_triggeredCheckpointIds);

  /// 更新会话配置（仅在 idle 或 paused 时允许）
  void updateSession(TimerSession newSession) {
    session = newSession;
    if (_status == TimerStatus.idle) {
      reset();
    }
  }

  /// 启动或继续计时
  void start() {
    if (_status == TimerStatus.running) return;

    if (_status == TimerStatus.completed) {
      reset();
    }

    _status = TimerStatus.running;
    _referenceTime = DateTime.now();
    _startTicker();
    onStatusChanged?.call(_status);
  }

  /// 暂停计时
  void pause() {
    if (_status != TimerStatus.running) return;

    _tickerTimer?.cancel();
    _tickerTimer = null;

    if (_referenceTime != null) {
      _baseElapsedSeconds +=
          DateTime.now().difference(_referenceTime!).inSeconds;
      _referenceTime = null;
    }

    _status = TimerStatus.paused;
    onStatusChanged?.call(_status);
  }

  /// 重置计时器回到初始状态
  void reset() {
    _tickerTimer?.cancel();
    _tickerTimer = null;
    _referenceTime = null;
    _baseElapsedSeconds = 0;
    _currentElapsedSeconds = 0;
    _triggeredCheckpointIds.clear();

    _status = TimerStatus.idle;
    onStatusChanged?.call(_status);
    onTick?.call(remainingSeconds, _currentElapsedSeconds);
  }

  /// 供外部显式校准时间（例如手机从后台唤醒、锁屏恢复）
  void calibrateWithCurrentTime() {
    if (_status != TimerStatus.running || _referenceTime == null) return;
    _computeCurrentTimeAndCheck();
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    // 采用 500ms 脉冲检查，既保证秒级响应度，又兼顾极低 CPU 开销
    _tickerTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _computeCurrentTimeAndCheck(),
    );
  }

  void _computeCurrentTimeAndCheck() {
    if (_status != TimerStatus.running || _referenceTime == null) return;

    final actualDeltaSeconds =
        DateTime.now().difference(_referenceTime!).inSeconds;
    final totalElapsed = _baseElapsedSeconds + actualDeltaSeconds;

    if (totalElapsed != _currentElapsedSeconds) {
      _currentElapsedSeconds = totalElapsed;
      onTick?.call(remainingSeconds, _currentElapsedSeconds);
      _checkCheckpoints();

      // 倒计时到达终点检查
      if (session.mode == TimerMode.countdown &&
          _currentElapsedSeconds >= session.totalDurationSeconds) {
        _currentElapsedSeconds = session.totalDurationSeconds;
        _completeTimer();
      }
    }
  }

  void _checkCheckpoints() {
    for (final cp in session.checkpoints) {
      if (!cp.isEnabled) continue;
      if (_triggeredCheckpointIds.contains(cp.id)) continue;

      bool shouldTrigger = false;
      if (cp.triggerType == CheckpointTriggerType.remaining) {
        if (session.mode == TimerMode.countdown &&
            remainingSeconds <= cp.offsetSeconds) {
          shouldTrigger = true;
        }
      } else if (cp.triggerType == CheckpointTriggerType.elapsed) {
        if (_currentElapsedSeconds >= cp.offsetSeconds) {
          shouldTrigger = true;
        }
      }

      if (shouldTrigger) {
        _triggeredCheckpointIds.add(cp.id);
        onCheckpointTriggered?.call(cp);
      }
    }
  }

  void _completeTimer() {
    _tickerTimer?.cancel();
    _tickerTimer = null;
    _referenceTime = null;
    _status = TimerStatus.completed;

    onStatusChanged?.call(_status);
    onTick?.call(0, session.totalDurationSeconds);
    onCompleted?.call();
  }

  void dispose() {
    _tickerTimer?.cancel();
    _tickerTimer = null;
  }
}
