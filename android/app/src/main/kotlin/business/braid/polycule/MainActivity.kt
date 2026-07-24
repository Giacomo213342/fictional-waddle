package business.braid.polycule

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// The complete Flutter application must always remain behind Android's
// keyguard. Incoming full-screen intents target the isolated native
// IncomingCallActivity supplied by polycule_call_notifications instead.
class MainActivity : FlutterActivity() {
    private var startedAsExternalShare = false

    override fun onCreate(savedInstanceState: Bundle?) {
        startedAsExternalShare = intent.isShareIntent()
        if (startedAsExternalShare) {
            // A cold external share is its own transient task. Keeping it out
            // of recents prevents Android from restoring a consumed /share
            // route after the payload has already been cleared.
            intent.addFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
        }
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(MatrixStoreLockPlugin())
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "business.braid.polycule/intent_lifecycle",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "consumeShareIntent" -> {
                    consumeShareIntent()
                    result.success(null)
                }
                "cancelShareIntent" -> {
                    result.success(cancelShareIntent())
                }
                else -> result.notImplemented()
            }
        }
        MediaUploadWorker.attachScheduler(
            applicationContext,
            flutterEngine.dartExecutor.binaryMessenger,
        )
    }

    private fun consumeShareIntent() {
        val currentIntent = intent ?: return
        if (!currentIntent.isShareIntent()) {
            return
        }
        clearSharePayload(currentIntent)
        startedAsExternalShare = false
        setTaskExcludedFromRecents(false)
    }

    private fun cancelShareIntent(): Boolean {
        val currentIntent = intent ?: return false
        if (!currentIntent.isShareIntent()) {
            return false
        }
        clearSharePayload(currentIntent)
        if (!startedAsExternalShare) {
            return false
        }
        startedAsExternalShare = false
        finishAndRemoveTask()
        return true
    }

    private fun clearSharePayload(currentIntent: Intent) {
        currentIntent.action = Intent.ACTION_MAIN
        currentIntent.type = null
        currentIntent.data = null
        currentIntent.clipData = null
        currentIntent.removeExtra(Intent.EXTRA_STREAM)
        currentIntent.removeExtra(Intent.EXTRA_TEXT)
        currentIntent.removeExtra(Intent.EXTRA_HTML_TEXT)
        setIntent(currentIntent)
    }

    private fun setTaskExcludedFromRecents(excluded: Boolean) {
        val activityManager =
            getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        activityManager.appTasks
            .firstOrNull { it.taskInfo.taskId == taskId }
            ?.setExcludeFromRecents(excluded)
    }

    private fun Intent?.isShareIntent(): Boolean =
        this?.action == Intent.ACTION_SEND ||
            this?.action == Intent.ACTION_SEND_MULTIPLE
}
