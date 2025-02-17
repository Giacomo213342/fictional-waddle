import android.content.Context
import business.braid.polycule.MainActivity
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader
import org.unifiedpush.flutter.connector.UnifiedPushReceiver

class UnifiedPushReceiver : UnifiedPushReceiver() {
    override fun getEngine(context: Context): FlutterEngine {
        var engine = MainActivity.engine
        if (engine == null) {
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
