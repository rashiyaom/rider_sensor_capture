package com.example.ride_sensor_capture

import android.content.Intent
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "ride_sensor_capture/recording_lifetime"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        try {
                            val intent = Intent(this, RideRecordingForegroundService::class.java)
                            intent.action = RideRecordingForegroundService.ACTION_START
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                startForegroundService(intent)
                            } else {
                                startService(intent)
                            }
                            result.success(true)
                        } catch (error: Exception) {
                            result.error("recording_service_start_failed", error.message, null)
                        }
                    }
                    "stop" -> {
                        try {
                            val intent = Intent(this, RideRecordingForegroundService::class.java)
                            intent.action = RideRecordingForegroundService.ACTION_STOP
                            startService(intent)
                            result.success(true)
                        } catch (error: Exception) {
                            result.error("recording_service_stop_failed", error.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
