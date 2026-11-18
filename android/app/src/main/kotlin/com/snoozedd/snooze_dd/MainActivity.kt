package com.snoozedd.snooze_dd

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.snoozedd.snooze_dd/background_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startForegroundService" -> {
                    val title = call.argument<String>("title") ?: "专注计时中"
                    val content = call.argument<String>("content") ?: "正在专注中..."
                    TimerForegroundService.start(this, title, content)
                    result.success(true)
                }
                "updateForegroundService" -> {
                    val title = call.argument<String>("title") ?: "专注计时中"
                    val content = call.argument<String>("content") ?: "正在专注中..."
                    TimerForegroundService.update(this, title, content)
                    result.success(true)
                }
                "stopForegroundService" -> {
                    TimerForegroundService.stop(this)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
