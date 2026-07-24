package business.braid.polycule

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import java.util.UUID
import java.util.concurrent.Executors
import java.util.concurrent.Semaphore

class MatrixStoreLockPlugin : FlutterPlugin {
    private var channel: MethodChannel? = null
    private val ownerTokens = mutableSetOf<String>()
    @Volatile private var attached = false

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        attached = true
        channel = MethodChannel(binding.binaryMessenger, CHANNEL).also { methodChannel ->
            methodChannel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "acquire" -> acquire(result)
                    "release" -> {
                        val token = call.argument<String>("token")
                        if (token != null) {
                            release(token)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        attached = false
        channel?.setMethodCallHandler(null)
        channel = null
        val permitsToRelease = synchronized(ownerTokens) {
            val count = ownerTokens.size
            ownerTokens.clear()
            count
        }
        if (permitsToRelease > 0) {
            storeSemaphore.release(permitsToRelease)
        }
    }

    private fun acquire(result: MethodChannel.Result) {
        executor.execute {
            storeSemaphore.acquire()
            val token = UUID.randomUUID().toString()
            val accepted = synchronized(ownerTokens) {
                if (attached) {
                    ownerTokens.add(token)
                    true
                } else {
                    false
                }
            }
            if (!accepted) {
                storeSemaphore.release()
                return@execute
            }
            mainHandler.post {
                if (attached) {
                    result.success(token)
                } else {
                    release(token)
                }
            }
        }
    }

    private fun release(token: String) {
        val owned = synchronized(ownerTokens) { ownerTokens.remove(token) }
        if (owned) {
            storeSemaphore.release()
        }
    }

    companion object {
        private const val CHANNEL = "polycule.matrix_store_lock"
        private val storeSemaphore = Semaphore(1, true)
        private val executor = Executors.newCachedThreadPool()
        private val mainHandler = Handler(Looper.getMainLooper())
    }
}
