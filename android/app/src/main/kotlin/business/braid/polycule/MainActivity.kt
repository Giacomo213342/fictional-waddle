package business.braid.polycule

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

// The complete Flutter application must always remain behind Android's
// keyguard. Incoming full-screen intents target the isolated native
// IncomingCallActivity supplied by polycule_call_notifications instead.
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(MatrixStoreLockPlugin())
        MediaUploadWorker.attachScheduler(
            applicationContext,
            flutterEngine.dartExecutor.binaryMessenger,
        )
    }
}
