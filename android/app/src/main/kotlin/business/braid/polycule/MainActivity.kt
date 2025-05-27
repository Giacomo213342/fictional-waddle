package business.braid.polycule

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return provideEngine(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // do nothing, because the engine was configured in provideEngine
    }

    companion object {
        // ensure we never have two Flutter engines running at the same time
        // related : android:launchMode="singleTask"
        var engine: FlutterEngine? = null
        fun provideEngine(context: Context): FlutterEngine {
            // Reuse the present Flutter engine if possible.
            // Flutter engine with empty VM arguments and disabled automatic plugin registration
            // https://api.flutter.dev/javadoc/io/flutter/embedding/engine/FlutterEngine.html#%3Cinit%3E(android.content.Context,java.lang.String%5B%5D,boolean,boolean)
            val eng = engine ?: FlutterEngine(context, emptyArray(), true, false)
            engine = eng
            return eng
        }
    }
}
