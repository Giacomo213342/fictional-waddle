import android.content.Context
import business.braid.polycule.MainActivity
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader
import org.unifiedpush.flutter.connector.UnifiedPushService
class UnifiedPushService : UnifiedPushService() {
    override fun getEngine(context: Context): FlutterEngine {
        // acquire the Flutter engine from the main activity when running in foreground
        var engine = MainActivity.engine
        if (engine == null) {
            // if there's no Flutter engine running in foreground, create a new one with
            // a custom VM entrypoint
            engine = MainActivity.provideEngine(context)
            engine.localizationPlugin.sendLocalesToFlutter(
                context.resources.configuration
            )

            val flutterLoader: FlutterLoader = FlutterInjector.instance().flutterLoader()

            if (!flutterLoader.initialized()) {
                throw AssertionError(
                    "DartEntrypoints can only be created once a FlutterEngine is created."
                )
            }

            // use the custom push handler entrypoint to avoid calling `runApp` in background
            val entrypoint = DartExecutor.DartEntrypoint(
                flutterLoader.findAppBundlePath(),
                "lib/src/utils/matrix/push_handler.dart",
                "pushEntrypoint",
            )

            engine.dartExecutor.executeDartEntrypoint(
                entrypoint
            )
        }
        return engine
    }
}
