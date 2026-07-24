package business.braid.polycule

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// The complete Flutter application must always remain behind Android's
// keyguard. Incoming full-screen intents target the isolated native
// IncomingCallActivity supplied by polycule_call_notifications instead.
class MainActivity : FlutterActivity() {
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
        if (
            currentIntent.action != Intent.ACTION_SEND &&
            currentIntent.action != Intent.ACTION_SEND_MULTIPLE
        ) {
            return
        }
        currentIntent.action = Intent.ACTION_MAIN
        currentIntent.type = null
        currentIntent.data = null
        currentIntent.clipData = null
        currentIntent.removeExtra(Intent.EXTRA_STREAM)
        currentIntent.removeExtra(Intent.EXTRA_TEXT)
        currentIntent.removeExtra(Intent.EXTRA_HTML_TEXT)
        setIntent(currentIntent)
    }
}
