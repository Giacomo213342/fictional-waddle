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
import androidx.core.app.NotificationCompat.CallStyle
import androidx.core.app.Person
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
        channel = MethodChannel(
            binding.binaryMessenger,
            "polycule.call_notifications",
        )
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
                "showOngoingCall" -> {
                    showOngoingCall(requireNotNull(call.arguments as? Map<*, *>))
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
                    IncomingCallStateStore.clear(context, callId)
                    CallForegroundService.stop(context)
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
        val requestedExpiry = System.currentTimeMillis() + timeoutMs
        val expiresAt = IncomingCallStateStore.resolveExpiry(
            context,
            callId,
            requestedExpiry,
        )
        val remainingMs = expiresAt - System.currentTimeMillis()
        if (remainingMs <= 0L) return

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

        val ringtoneUri = callRingtoneUri()
        val caller = Person.Builder()
            .setName(callerName)
            .setImportant(true)
            .build()
        val notification = NotificationCompat.Builder(context, CallNotificationContract.CHANNEL_ID)
            .setSmallIcon(icon)
            .setContentTitle(callerName)
            .setContentText(if (video) "Incoming video call" else "Incoming call")
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setOnlyAlertOnce(true)
            .setTimeoutAfter(remainingMs)
            .setContentIntent(openIntent)
            .setFullScreenIntent(openIntent, true)
            .setSound(ringtoneUri)
            .setVibrate(longArrayOf(0L, 700L, 500L, 700L))
            .setStyle(CallStyle.forIncomingCall(caller, declineIntent, answerIntent))
            .build()

        notification.flags = notification.flags or Notification.FLAG_INSISTENT

        NotificationManagerCompat.from(context).notify(notificationId, notification)
    }

    private fun showOngoingCall(arguments: Map<*, *>) {
        val notificationId = requireNotNull(arguments["notificationId"] as? Int)
        val payload = requireNotNull(arguments["payload"] as? String)
        val callId = requireNotNull(arguments["callId"] as? String)
        val peerName = requireNotNull(arguments["peerName"] as? String)
        val connected = arguments["connected"] as? Boolean ?: false
        val hangupActionId = requireNotNull(arguments["hangupActionId"] as? String)

        ensureActiveChannel()
        IncomingCallStateStore.clear(context, callId)
        closeSurface(callId)
        // Cancel first so Android releases the incoming channel's insistent
        // ringtone before the same notification ID becomes the foreground
        // service notification on the silent active-call channel.
        NotificationManagerCompat.from(context).cancel(notificationId)

        val openIntent = mainActivityIntent(
            notificationId,
            payload,
            null,
        )
        val hangupIntent = surfaceIntent(
            notificationId,
            payload,
            callId,
            peerName,
            false,
            hangupActionId,
            Long.MAX_VALUE,
        )
        val notification = NotificationCompat.Builder(
            context,
            CallNotificationContract.ACTIVE_CHANNEL_ID,
        )
            .setSmallIcon(notificationIcon())
            .setContentTitle(peerName)
            .setContentText(if (connected) "Call in progress" else "Connecting call…")
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .setAutoCancel(false)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setUsesChronometer(connected)
            .setWhen(System.currentTimeMillis())
            .setContentIntent(openIntent)
            .addAction(0, "Hang up", hangupIntent)
            .build()

        CallForegroundService.start(context, notificationId, callId, notification)
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

    private fun mainActivityIntent(
        notificationId: Int,
        payload: String,
        selectedAction: String?,
    ): PendingIntent {
        val intent = requireNotNull(
            context.packageManager.getLaunchIntentForPackage(context.packageName),
        ).apply {
            action = if (selectedAction == null) {
                CallNotificationContract.SELECT_NOTIFICATION
            } else {
                CallNotificationContract.SELECT_FOREGROUND_NOTIFICATION
            }
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra(CallNotificationContract.EXTRA_NOTIFICATION_ID, notificationId)
            putExtra(CallNotificationContract.EXTRA_PAYLOAD, payload)
            putExtra(CallNotificationContract.EXTRA_ACTION_ID, selectedAction)
            putExtra(CallNotificationContract.EXTRA_CANCEL_NOTIFICATION, false)
        }
        return PendingIntent.getActivity(
            context,
            notificationId,
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
        val ringtoneUri = callRingtoneUri()
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

    private fun ensureActiveChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            CallNotificationContract.ACTIVE_CHANNEL_ID,
            "Active calls",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Ongoing Matrix calls"
            setSound(null, null)
            enableVibration(false)
        }
        context.getSystemService(NotificationManager::class.java)
            .createNotificationChannel(channel)
    }

    private fun callRingtoneUri() =
        RingtoneManager.getActualDefaultRingtoneUri(
            context,
            RingtoneManager.TYPE_RINGTONE,
        ) ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)

    private fun notificationIcon() = context.resources.getIdentifier(
        "ic_launcher_foreground",
        "drawable",
        context.packageName,
    ).takeIf { it != 0 } ?: context.applicationInfo.icon

    private fun closeSurface(callId: String?) {
        context.sendBroadcast(
            Intent(CallNotificationContract.ACTION_CLOSE_SURFACE)
                .setPackage(context.packageName)
                .putExtra(CallNotificationContract.EXTRA_CALL_ID, callId),
        )
    }
}
