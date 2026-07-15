package business.braid.polycule

import android.content.Intent
import androidx.core.app.Person
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "polycule.shortcuts"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "publishConversationShortcut") {
                val id = call.argument<String>("id")
                val name = call.argument<String>("name")

                if (id != null && name != null) {
                    val person = Person.Builder()
                        .setName(name)
                        .setKey(id)
                        .build()

                    val intent = Intent(this@MainActivity, MainActivity::class.java)
                    intent.action = Intent.ACTION_VIEW

                    val shortcut = ShortcutInfoCompat.Builder(this@MainActivity, id)
                        .setShortLabel(name)
                        .setLongLabel(name)
                        .setLongLived(true)
                        .setPerson(person)
                        .setIntent(intent)
                        .build()

                    ShortcutManagerCompat.pushDynamicShortcut(this@MainActivity, shortcut)
                    result.success(true)
                } else {
                    result.error("INVALID_ARGS", "Missing id or name", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
