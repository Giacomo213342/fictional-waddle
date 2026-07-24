package business.braid.polycule

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import org.unifiedpush.flutter.connector.UnifiedPushService

class PolyculeUnifiedPushService : UnifiedPushService() {
    override fun getEngine(context: Context): FlutterEngine {
        return FlutterEngine(context).apply {
            plugins.add(MatrixStoreLockPlugin())
            localizationPlugin.sendLocalesToFlutter(
                context.resources.configuration,
            )
            dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault(),
                listOf("--unifiedpush-bg"),
            )
        }
    }
}
