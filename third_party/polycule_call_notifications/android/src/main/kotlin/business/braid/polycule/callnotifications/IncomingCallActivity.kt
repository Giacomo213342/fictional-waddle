package business.braid.polycule.callnotifications

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Color
import android.graphics.Typeface
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.app.NotificationManagerCompat

/**
 * The only Polycule surface allowed above Android's keyguard.
 *
 * This activity deliberately contains no Flutter view, navigation, room data,
 * or account controls. Any action is forwarded to the normal MainActivity,
 * which remains behind the keyguard until Android authenticates the user.
 */
class IncomingCallActivity : Activity() {
    private var callId: String? = null
    private var closeReceiverRegistered = false
    private val timeoutHandler = Handler(Looper.getMainLooper())
    private val finishAtTimeout = Runnable { finishAndRemoveTask() }

    private val closeReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val endingCallId = intent?.getStringExtra(CallNotificationContract.EXTRA_CALL_ID)
            if (endingCallId == null || endingCallId == callId) finishAndRemoveTask()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON,
            )
        }
        registerCloseReceiver()
        consumeIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        consumeIntent(intent)
    }

    override fun onDestroy() {
        timeoutHandler.removeCallbacks(finishAtTimeout)
        if (closeReceiverRegistered) unregisterReceiver(closeReceiver)
        super.onDestroy()
    }

    private fun consumeIntent(intent: Intent) {
        callId = intent.getStringExtra(CallNotificationContract.EXTRA_CALL_ID)
        val selectedAction =
            intent.getStringExtra(CallNotificationContract.EXTRA_SELECTED_ACTION)
        if (selectedAction != null) {
            forwardToPolycule(selectedAction)
            return
        }
        timeoutHandler.removeCallbacks(finishAtTimeout)
        val expiresAt = intent.getLongExtra(
            CallNotificationContract.EXTRA_EXPIRES_AT,
            System.currentTimeMillis(),
        )
        val remaining = expiresAt - System.currentTimeMillis()
        if (remaining <= 0) {
            finishAndRemoveTask()
            return
        }
        timeoutHandler.postDelayed(finishAtTimeout, remaining)
        setContentView(buildCallSurface(intent))
    }

    private fun buildCallSurface(intent: Intent): View {
        val callerName = intent.getStringExtra(CallNotificationContract.EXTRA_CALLER_NAME)
            ?: "Matrix call"
        val video = intent.getBooleanExtra(CallNotificationContract.EXTRA_VIDEO, false)
        val density = resources.displayMetrics.density
        fun dp(value: Int) = (value * density).toInt()

        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(dp(28), dp(48), dp(28), dp(48))
            setBackgroundColor(Color.rgb(10, 15, 18))

            addView(TextView(context).apply {
                text = callerName
                setTextColor(Color.WHITE)
                textSize = 26f
                gravity = Gravity.CENTER
                typeface = Typeface.create(Typeface.MONOSPACE, Typeface.NORMAL)
            })
            addView(TextView(context).apply {
                text = if (video) "incoming video call" else "incoming call"
                setTextColor(Color.rgb(170, 190, 198))
                textSize = 15f
                gravity = Gravity.CENTER
                setPadding(0, dp(10), 0, dp(44))
                typeface = Typeface.create(Typeface.MONOSPACE, Typeface.NORMAL)
            })
            addView(LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER
                addView(callButton("Decline", Color.rgb(160, 35, 45)) {
                    forwardToPolycule("polycule.call.decline")
                })
                addView(callButton("Answer", Color.rgb(30, 125, 75)) {
                    forwardToPolycule("polycule.call.answer")
                })
            })
            addView(Button(context).apply {
                text = "Open Polycule"
                isAllCaps = false
                setTextColor(Color.rgb(205, 225, 232))
                setBackgroundColor(Color.TRANSPARENT)
                setPadding(dp(16), dp(32), dp(16), dp(8))
                setOnClickListener { forwardToPolycule(null) }
            })
        }
    }

    private fun callButton(label: String, color: Int, action: () -> Unit): Button =
        Button(this).apply {
            text = label
            isAllCaps = false
            setTextColor(Color.WHITE)
            setBackgroundColor(color)
            setPadding(0, 0, 0, 0)
            setOnClickListener { action() }
            layoutParams = LinearLayout.LayoutParams(dp(132), dp(56)).apply {
                marginStart = dp(8)
                marginEnd = dp(8)
            }
        }

    private fun forwardToPolycule(actionId: String?) {
        if (actionId != null) {
            val payload = intent.getStringExtra(CallNotificationContract.EXTRA_PAYLOAD)
            val currentCallId = intent.getStringExtra(CallNotificationContract.EXTRA_CALL_ID)
            if (payload != null && currentCallId != null) {
                CallActionStore.persist(
                    this,
                    payload,
                    actionId,
                    currentCallId,
                    intent.getLongExtra(
                        CallNotificationContract.EXTRA_EXPIRES_AT,
                        System.currentTimeMillis() + 60_000L,
                    ),
                )
            }
            NotificationManagerCompat.from(this).cancel(
                intent.getIntExtra(CallNotificationContract.EXTRA_NOTIFICATION_ID, 0),
            )
        }
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName) ?: run {
            finishAndRemoveTask()
            return
        }
        launchIntent.action = if (actionId == null) {
            CallNotificationContract.SELECT_NOTIFICATION
        } else {
            CallNotificationContract.SELECT_FOREGROUND_NOTIFICATION
        }
        launchIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or
            Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        launchIntent.putExtra(
            CallNotificationContract.EXTRA_NOTIFICATION_ID,
            intent.getIntExtra(CallNotificationContract.EXTRA_NOTIFICATION_ID, 0),
        )
        launchIntent.putExtra(
            CallNotificationContract.EXTRA_PAYLOAD,
            intent.getStringExtra(CallNotificationContract.EXTRA_PAYLOAD),
        )
        launchIntent.putExtra(CallNotificationContract.EXTRA_ACTION_ID, actionId)
        launchIntent.putExtra(CallNotificationContract.EXTRA_CANCEL_NOTIFICATION, false)
        startActivity(launchIntent)
        finishAndRemoveTask()
    }

    private fun registerCloseReceiver() {
        val filter = IntentFilter(CallNotificationContract.ACTION_CLOSE_SURFACE)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(closeReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("DEPRECATION")
            registerReceiver(closeReceiver, filter)
        }
        closeReceiverRegistered = true
    }

    private fun dp(value: Int) = (value * resources.displayMetrics.density).toInt()
}
