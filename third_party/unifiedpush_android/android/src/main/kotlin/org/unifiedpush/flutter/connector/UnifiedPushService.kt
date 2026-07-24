package org.unifiedpush.flutter.connector

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import org.json.JSONObject
import java.security.MessageDigest
import org.unifiedpush.android.connector.FailedReason
import org.unifiedpush.android.connector.PushService
import org.unifiedpush.android.connector.data.PushEndpoint
import org.unifiedpush.android.connector.data.PushMessage
import org.unifiedpush.flutter.connector.Plugin.Companion.dispatcher

/**
 * Implementation of [PushService] for the flutter library, forward events to
 * flutter engine through [Plugin].
 *
 * If you need to use your own service, for instance to control the flutter
 * engine, by overriding [getEngine], please update your Manifest:
 *
 * ```xml
 * <manifest xmlns:android="http://schemas.android.com/apk/res/android"
 *     xmlns:tools="http://schemas.android.com/tools">
 *     <application "...">
 *         <!-- ... -->
 *         <service android:name="org.unifiedpush.flutter.connector.UnifiedPushService"
 *             tools:node="replace">
 *         </service>
 *     </application>
 * </manifest>
 * ```
 */
open class UnifiedPushService: PushService() {

    override fun onCreate() {
        Log.d(TAG, "Starting UnifiedPushService")
        Plugin.calls ?: run {
            val registry = getEngine(this).plugins
            (registry.get(Plugin::class.java) as? Plugin)
                ?: Plugin().also { registry.add(it) }
        }
        super.onCreate()
        Log.d(TAG, "UnifiedPushService started")
    }

    /**
     * Returns [FlutterEngine] used when creating [Plugin]
     * if it doesn't exist yet. Plugin is then added to its
     * plugins registry
     */
    open fun getEngine(context: Context): FlutterEngine {
        return FlutterEngine(context).apply {
            localizationPlugin.sendLocalesToFlutter(
                context.resources.configuration
            )
            dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault().also {
                    it
                },
                listOf("--unifiedpush-bg")
            )
        }
    }

    override fun onMessage(message: PushMessage, instance: String) {
        Log.d(TAG, "onMessage")
        if (isDuplicatePush(message, instance)) {
            Log.i(TAG, "Dropping duplicate push payload for $instance")
            return
        }
        val data = mapOf(
            PLUGIN_ARG_INSTANCE to instance,
            PLUGIN_ARG_MESSAGE_CONTENT to message.content,
            PLUGIN_ARG_MESSAGE_DECRYPTED to message.decrypted,
        )
        CoroutineScope(dispatcher).launch {
            Plugin.calls?.emit(Call(PLUGIN_CALL_MESSAGE, data))
            coroutineContext.cancel()
        }
    }

    override fun onNewEndpoint(endpoint: PushEndpoint, instance: String) {
        Log.d(TAG, "onNewEndpoint")
        val data = mapOf(
            PLUGIN_ARG_INSTANCE to instance,
            PLUGIN_ARG_ENDPOINT_URL to endpoint.url,
            PLUGIN_ARG_ENDPOINT_KEY_PUBKEY to endpoint.pubKeySet?.pubKey,
            PLUGIN_ARG_ENDPOINT_KEY_AUTH to endpoint.pubKeySet?.auth,
            PLUGIN_ARG_ENDPOINT_TEMP to endpoint.temporary
        )
        CoroutineScope(dispatcher).launch {
            Plugin.calls?.emit(Call(PLUGIN_CALL_NEW_ENDPOINT, data))
            coroutineContext.cancel()
        }
    }

    override fun onRegistrationFailed(reason: FailedReason, instance: String) {
        Log.d(TAG, "onRegistrationFailed")
        val data = mapOf(
            PLUGIN_ARG_INSTANCE to instance,
            PLUGIN_ARG_REASON to reason.name
        )
        CoroutineScope(dispatcher).launch {
            Plugin.calls?.emit(Call(PLUGIN_CALL_REGISTRATION_FAILED, data))
            coroutineContext.cancel()
        }
    }

    override fun onUnregistered(instance: String) {
        Log.d(TAG, "onUnregistered")
        val data = mapOf(PLUGIN_ARG_INSTANCE to instance)
        CoroutineScope(dispatcher).launch {
            Plugin.calls?.emit(Call(PLUGIN_CALL_UNREGISTERED, data))
            coroutineContext.cancel()
        }
    }

    override fun onTempUnavailable(instance: String) {
        Log.d(TAG, "onTempUnavailable")
        val data = mapOf(PLUGIN_ARG_INSTANCE to instance)
        CoroutineScope(dispatcher).launch {
            Plugin.calls?.emit(Call(PLUGIN_CALL_TEMP_UNAVAILABLE, data))
            coroutineContext.cancel()
        }
    }

    private fun isDuplicatePush(message: PushMessage, instance: String): Boolean {
        val digest = MessageDigest.getInstance("SHA-256")
        digest.update(instance.toByteArray(Charsets.UTF_8))
        digest.update(0.toByte())
        val eventId = runCatching {
            JSONObject(String(message.content, Charsets.UTF_8))
                .optJSONObject("notification")
                ?.optString("event_id")
                ?.takeIf { it.isNotBlank() }
        }.getOrNull()
        digest.update(
            eventId?.toByteArray(Charsets.UTF_8) ?: message.content,
        )
        val fingerprint = digest.digest().joinToString("") { "%02x".format(it) }
        val key = "$SEEN_PREFIX$fingerprint"
        val now = System.currentTimeMillis()
        val preferences = getSharedPreferences(DEDUPLICATION_STORE, Context.MODE_PRIVATE)

        synchronized(deduplicationLock) {
            val lastSeen = preferences.getLong(key, 0L)
            if (lastSeen > 0 && now - lastSeen < DUPLICATE_WINDOW_MS) {
                return true
            }
            val editor = preferences.edit().putLong(key, now)
            if (preferences.all.size > MAXIMUM_SEEN_PAYLOADS) {
                preferences.all.forEach { (storedKey, value) ->
                    val timestamp = value as? Long ?: return@forEach
                    if (storedKey.startsWith(SEEN_PREFIX) &&
                        now - timestamp > RETENTION_MS) {
                        editor.remove(storedKey)
                    }
                }
            }
            // commit() makes the fingerprint visible before a second service
            // callback can launch another Flutter engine.
            editor.commit()
            return false
        }
    }

    internal companion object {
        private const val TAG = "UnifiedPushService"
        private const val DEDUPLICATION_STORE = "polycule_unifiedpush_seen"
        private const val SEEN_PREFIX = "payload_"
        private const val DUPLICATE_WINDOW_MS = 15 * 60 * 1000L
        private const val RETENTION_MS = 24 * 60 * 60 * 1000L
        private const val MAXIMUM_SEEN_PAYLOADS = 128
        private val deduplicationLock = Any()
    }
}
