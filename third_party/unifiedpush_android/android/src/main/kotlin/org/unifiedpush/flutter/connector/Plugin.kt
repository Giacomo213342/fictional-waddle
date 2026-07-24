package org.unifiedpush.flutter.connector

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.Person
import androidx.core.content.LocusIdCompat
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.launch
import org.unifiedpush.android.connector.UnifiedPush as up

/**
 * Plugin to interact with the flutter side
 */
class Plugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var mContext : Context? = null
    private var activityContext: Activity? = null
    private var job: Job? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private var pluginChannel: MethodChannel? = null
    private var conversationChannel: MethodChannel? = null
    // Allow up to 20 calls during initialization
    val calls = MutableSharedFlow<Call>(replay = 20)

    init {
        Log.d(TAG, "Init new Plugin: $this")
        Plugin.calls = calls
    }

    /**
     * Get list of distributors
     *
     * argv1 = features (not used for android at this moment)
     */
    private fun getDistributors(context: Context,
                                result: MethodChannel.Result){
        // We ignore features at this moment
        // val features = parseFeatures(args?.get(0))
        val distributors = up.getDistributors(context)
        result.success(distributors)
    }

    private fun getDistributor(context: Context,
                               result: MethodChannel.Result) {
        result.success(up.getAckDistributor(context))
    }

    private fun saveDistributor(context: Context,
                                args: ArrayList<String>?,
                                result: MethodChannel.Result) {
        val distributor = args?.get(0) ?: run {
            result.success(false)
            return
        }
        up.saveDistributor(context, distributor)
        result.success(true)
    }

    /**
     * Register instance
     * instance = argv1
     * features = argv2 (not used for android at this moment)
     * message for distrib = argv3
     * vapid = argv4
     */
    private fun register(context: Context,
                         args: ArrayList<String>?,
                         result: MethodChannel.Result) {
        val instance = args?.get(0)
        val message = args?.get(2)
        val vapid = args?.get(3)
        // We ignore features at this moment
        // val features = parseFeatures(args?.get(1))
        Log.d(TAG, "registerApp: instance=$instance")
        if (instance.isNullOrBlank()) {
            up.register(context, messageForDistributor = message, vapid = vapid)
        } else {
            up.register(context, instance = instance, messageForDistributor = message, vapid = vapid)
        }
        result.success(true)
    }

    private fun tryUseCurrentOrDefaultDistributor(result: MethodChannel.Result) {
        activityContext?.let { context ->
            up.tryUseCurrentOrDefaultDistributor(context) { success ->
                result.success(success)
            }
        } ?: run {
            result.success(false)
        }
    }

    private fun unregister(context: Context,
                           args: ArrayList<String>?,
                           result: MethodChannel.Result) {
        val instance = args?.get(0)
        Log.d(TAG, "unregisterApp: instance=$instance")
        if (instance.isNullOrEmpty()) {
            up.unregister(context)
        } else {
            up.unregister(context, instance)
        }
        result.success(true)
    }

    /*
    Parse Known features, at this moment we don't use any with android
    private fun parseFeatures(arg: String?): ArrayList<String> {
        val jsonArray = JSONArray(arg ?: "[]")
        val knownFeatures = arrayOf(up.FEATURE_BYTES_MESSAGE)
        return (0 until jsonArray.length()).mapNotNull {
            val feature = jsonArray.getString(it)
            if (knownFeatures.contains(feature)) {
                feature
            } else {
                null
            }
        } as ArrayList<String>
    }
    */

    private fun onInitialized(result: MethodChannel.Result) {
        // job = CoroutineScope(Dispatchers.IO + SupervisorJob()).launch {
        job = CoroutineScope(dispatcher).launch {
            Log.d(TAG, "onInitialized, collecting calls")
            calls.collect {
                coroutineContext.ensureActive()
                Log.d(TAG, "Calling ${it.method}")
                mainHandler.post {
                    pluginChannel?.invokeMethod(it.method, it.data)
                }
            }
        }
        result.success(true)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityContext = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityContext = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityContext = binding.activity
    }

    override fun onDetachedFromActivity() {
        activityContext = null
    }

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine")
        mContext = binding.applicationContext
        pluginChannel = MethodChannel(binding.binaryMessenger, PLUGIN_CHANNEL).apply {
            setMethodCallHandler(this@Plugin)
        }
        conversationChannel = MethodChannel(
            binding.binaryMessenger,
            CONVERSATION_CHANNEL,
        ).apply {
            setMethodCallHandler { call, result ->
                if (call.method != "publishConversationShortcut") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                publishConversationShortcut(call, result)
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        Log.d(TAG, "onDetachedFromEngine")
        pluginChannel?.setMethodCallHandler(null)
        pluginChannel = null
        conversationChannel?.setMethodCallHandler(null)
        conversationChannel = null
        mContext = null
        job?.cancel()
        // A cached Android process can outlive its FlutterEngine. Do not leave
        // the service pointing at this plugin's uncollected flow, but also do
        // not clear a newer plugin instance that may already have replaced it.
        if (Plugin.calls === calls) {
            Plugin.calls = null
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "Method: ${call.method}")
        val args = call.arguments<ArrayList<String>>()
        when(call.method) {
            PLUGIN_EVENT_GET_DISTRIBUTORS -> getDistributors(mContext!!,result)
            PLUGIN_EVENT_GET_DISTRIBUTOR -> getDistributor(mContext!!, result)
            PLUGIN_EVENT_SAVE_DISTRIBUTOR -> saveDistributor(mContext!!, args, result)
            PLUGIN_EVENT_REGISTER_APP -> register(mContext!!, args, result)
            PLUGIN_EVENT_TRY_CURRENT_OR_DEFAULT_DISTRIBUTOR -> tryUseCurrentOrDefaultDistributor(result)
            PLUGIN_EVENT_UNREGISTER -> unregister(mContext!!, args, result)
            PLUGIN_EVENT_INITIALIZED -> onInitialized(result)
            else -> result.notImplemented()
        }
    }

    private fun publishConversationShortcut(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val context = mContext ?: run {
            result.error("NO_CONTEXT", "Android context is unavailable", null)
            return
        }
        val id = call.argument<String>("id")
        val name = call.argument<String>("name")
        val personName = call.argument<String>("personName") ?: name
        val personKey = call.argument<String>("personKey") ?: id
        if (id.isNullOrBlank() || name.isNullOrBlank() ||
            personName.isNullOrBlank() || personKey.isNullOrBlank()) {
            result.error("INVALID_ARGS", "Missing conversation identity", null)
            return
        }

        val launchIntent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
            ?.apply {
                action = Intent.ACTION_VIEW
                putExtra("polycule_conversation_id", id)
            }
            ?: run {
                result.error("NO_LAUNCH_INTENT", "App launch intent is unavailable", null)
                return
            }
        val person = Person.Builder()
            .setName(personName)
            .setKey(personKey)
            .setImportant(call.argument<Boolean>("important") == true)
            .build()
        val avatarBytes = call.argument<ByteArray>("avatarBytes")
        val avatarBitmap = avatarBytes
            ?.takeIf { it.isNotEmpty() }
            ?.let { BitmapFactory.decodeByteArray(it, 0, it.size) }
        val conversationIcon = avatarBitmap
            ?.let { IconCompat.createWithAdaptiveBitmap(it) }
            ?: IconCompat.createWithResource(context, context.applicationInfo.icon)
        val shortcut = ShortcutInfoCompat.Builder(context, id)
            .setShortLabel(name)
            .setLongLabel(name)
            .setIcon(conversationIcon)
            .setIntent(launchIntent)
            .setPerson(person)
            .setCategories(setOf(CONVERSATION_CATEGORY))
            .setLocusId(LocusIdCompat(id))
            .setLongLived(true)
            .setIsConversation()
            .build()

        result.success(ShortcutManagerCompat.pushDynamicShortcut(context, shortcut))
    }

    companion object {
        private const val TAG = "Plugin"
        private const val CONVERSATION_CHANNEL = "polycule.shortcuts"
        private const val CONVERSATION_CATEGORY =
            "business.braid.polycule.conversation"
        var calls: MutableSharedFlow<Call>? = null
        val dispatcher = Dispatchers.IO
    }
}
