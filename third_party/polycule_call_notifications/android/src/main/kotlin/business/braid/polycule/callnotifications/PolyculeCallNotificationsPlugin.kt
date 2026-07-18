package business.braid.polycule.callnotifications

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PolyculeCallNotificationsPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var context: Context
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "polycule.calls")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "showIncomingCall" -> {
                    showIncomingCall(requireNotNull(call.arguments as? Map<*, *>))
                    result.success(null)
                }
                "dismissIncomingCallSurface" -> {
                    closeSurface(call.argument<String>("callId"))
                    result.success(null)
                }
                "cancelCall" -> {
                    val id = requireNotNull(call.argument<Int>("notificationId"))
                    NotificationManagerCompat.from(context).cancel(id)
                    val callId = call.argument<String>("callId")
                    CallActionStore.clearForCall(context, callId)
                    closeSurface(callId)
                    result.success(null)
                }
                "getPendingCallAction" -> {
                    result.success(CallActionStore.read(context))
                }
                "acknowledgeCallAction" -> {
                    CallActionStore.acknowledge(
                        context,
                        requireNotNull(call.argument<String>("callId")),
                        requireNotNull(call.argument<String>("actionId")),
                    )
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (error: Throwable) {
            result.error("polycule_call_notification", error.message, null)
        }
    }

    private fun showIncomingCall(arguments: Map<*, *>) {
        val notificationId = requireNotNull(arguments["notificationId"] as? Int)
        val payload = requireNotNull(arguments["payload"] as? String)
        val callId = requireNotNull(arguments["callId"] as? String)
        val callerName = requireNotNull(arguments["callerName"] as? String)
        val video = arguments["video"] as? Boolean ?: false
        val timeoutMs = (arguments["timeoutMs"] as? Number)?.toLong() ?: 60_000L
        val answerActionId = requireNotNull(arguments["answerActionId"] as? String)
        val declineActionId = requireNotNull(arguments["declineActionId"] as? String)
        val expiresAt = System.currentTimeMillis() + timeoutMs

        ensureIncomingChannel()
        val openIntent = surfaceIntent(
            notificationId,
            payload,
            callId,
            callerName,
            video,
            null,
            expiresAt,
        )
        val answerIntent = surfaceIntent(
            notificationId,
            payload,
            callId,
            callerName,
            video,
            answerActionId,
            expiresAt,
        )
        val declineIntent = surfaceIntent(
            notificationId,
            payload,
            callId,
            callerName,
            video,
            declineActionId,
            expiresAt,
        )
        val icon = context.resources.getIdentifier(
            "ic_launcher_foreground",
            "drawable",
            context.packageName,
        ).takeIf { it != 0 } ?: context.applicationInfo.icon

        val ringtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
        val notification = NotificationCompat.Builder(context, CallNotificationContract.CHANNEL_ID)
            .setSmallIcon(icon)
            .setContentTitle(callerName)
            .setContentText(if (video) "Incoming video call" else "Incoming call")
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setTimeoutAfter(timeoutMs)
            .setContentIntent(openIntent)
            .setFullScreenIntent(openIntent, true)
            .setSound(ringtoneUri)
            .setVibrate(longArrayOf(0L, 700L, 500L, 700L))
            .addAction(0, "Decline", declineIntent)
            .addAction(0, "Answer", answerIntent)
            .build()

        notification.flags = notification.flags or Notification.FLAG_INSISTENT

        NotificationManagerCompat.from(context).notify(notificationId, notification)
    }

    private fun surfaceIntent(
        notificationId: Int,
        payload: String,
        callId: String,
        callerName: String,
        video: Boolean,
        selectedAction: String?,
        expiresAt: Long,
    ): PendingIntent {
        val intent = Intent(context, IncomingCallActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra(CallNotificationContract.EXTRA_NOTIFICATION_ID, notificationId)
            putExtra(CallNotificationContract.EXTRA_PAYLOAD, payload)
            putExtra(CallNotificationContract.EXTRA_CALL_ID, callId)
            putExtra(CallNotificationContract.EXTRA_CALLER_NAME, callerName)
            putExtra(CallNotificationContract.EXTRA_VIDEO, video)
            putExtra(CallNotificationContract.EXTRA_SELECTED_ACTION, selectedAction)
            putExtra(CallNotificationContract.EXTRA_EXPIRES_AT, expiresAt)
        }
        val actionOffset = when (selectedAction) {
            null -> 0
            else -> selectedAction.hashCode() and 0x7fff
        }
        return PendingIntent.getActivity(
            context,
            notificationId xor actionOffset,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun ensureIncomingChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val ringtoneAttributes = AudioAttributes.Builder()
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
            .build()
        val ringtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
        val channel = NotificationChannel(
            CallNotificationContract.CHANNEL_ID,
            "Incoming calls",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Incoming Matrix calls"
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            enableVibration(true)
            vibrationPattern = longArrayOf(0L, 700L, 500L, 700L)
            setSound(ringtoneUri, ringtoneAttributes)
        }
        context.getSystemService(NotificationManager::class.java)
            .createNotificationChannel(channel)
    }

    private fun closeSurface(callId: String?) {
        context.sendBroadcast(
            Intent(CallNotificationContract.ACTION_CLOSE_SURFACE)
                .setPackage(context.packageName)
                .putExtra(CallNotificationContract.EXTRA_CALL_ID, callId),
        )
    }
}
