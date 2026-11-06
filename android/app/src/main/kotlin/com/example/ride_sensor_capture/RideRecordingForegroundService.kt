package com.example.ride_sensor_capture

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.os.PowerManager

class RideRecordingForegroundService : Service() {
    private var wakeLock: PowerManager.WakeLock? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                @Suppress("DEPRECATION")
                stopForeground(true)
                stopSelf(startId)
                return START_NOT_STICKY
            }
            ACTION_START, null -> startRecordingLifetime()
            else -> stopSelf(startId)
        }
        return START_NOT_STICKY
    }

    private fun startRecordingLifetime() {
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION or
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        if (wakeLock?.isHeld != true) {
            val manager = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = manager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "$packageName:RideRecording",
            ).apply {
                setReferenceCounted(false)
                acquire()
            }
        }
    }

    private fun buildNotification(): Notification {
        val openApp = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = openApp?.let {
            val mutabilityFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_IMMUTABLE
            } else {
                0
            }
            val flags = PendingIntent.FLAG_UPDATE_CURRENT or mutabilityFlag
            PendingIntent.getActivity(
                this,
                0,
                it,
                flags,
            )
        }
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        builder
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Ride recording is active")
            .setContentText("Sensor and location capture may continue while the screen is locked.")
            .setCategory(Notification.CATEGORY_SERVICE)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
        if (pendingIntent != null) builder.setContentIntent(pendingIntent)
        return builder.build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Active ride recording",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Shows when ride sensor and location recording is active."
            setShowBadge(false)
        }
        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
            .createNotificationChannel(channel)
    }

    override fun onDestroy() {
        wakeLock?.let { lock ->
            if (lock.isHeld) lock.release()
        }
        wakeLock = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    companion object {
        const val ACTION_START = "com.example.ride_sensor_capture.START_RECORDING"
        const val ACTION_STOP = "com.example.ride_sensor_capture.STOP_RECORDING"
        private const val CHANNEL_ID = "active_ride_recording"
        private const val NOTIFICATION_ID = 4201
    }
}
