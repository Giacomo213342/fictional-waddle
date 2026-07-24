package business.braid.polycule.callnotifications

import android.app.Notification
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.IBinder
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat

/** Keeps WebRTC alive while an answered or outgoing call is in progress. */
class CallForegroundService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                val notificationId = intent.getIntExtra(EXTRA_NOTIFICATION_ID, 0)
                val notification = notificationFrom(intent) ?: run {
                    stopSelf(startId)
                    return START_NOT_STICKY
                }
                ServiceCompat.startForeground(
                    this,
                    notificationId,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_PHONE_CALL,
                )
            }
            else -> stopSelf(startId)
        }
        return START_REDELIVER_INTENT
    }

    @Suppress("DEPRECATION")
    private fun notificationFrom(intent: Intent): Notification? =
        if (android.os.Build.VERSION.SDK_INT >= 33) {
            intent.getParcelableExtra(EXTRA_NOTIFICATION, Notification::class.java)
        } else {
            intent.getParcelableExtra(EXTRA_NOTIFICATION)
        }

    companion object {
        private const val ACTION_START =
            "business.braid.polycule.callnotifications.START_CALL"
        private const val EXTRA_NOTIFICATION_ID = "notificationId"
        private const val EXTRA_NOTIFICATION = "notification"
        private const val EXTRA_CALL_ID = "callId"

        fun start(
            context: Context,
            notificationId: Int,
            callId: String,
            notification: Notification,
        ) {
            val intent = Intent(context, CallForegroundService::class.java)
                .setAction(ACTION_START)
                .putExtra(EXTRA_NOTIFICATION_ID, notificationId)
                .putExtra(EXTRA_NOTIFICATION, notification)
                .putExtra(EXTRA_CALL_ID, callId)
            ContextCompat.startForegroundService(context, intent)
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, CallForegroundService::class.java))
        }
    }
}
