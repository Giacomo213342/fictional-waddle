package business.braid.polycule.callnotifications

import android.content.Context

/** Durable single-call action queue shared by notification and Flutter engines. */
internal object CallActionStore {
    private const val PREFERENCES = "polycule.pending_call_action"
    private const val KEY_PAYLOAD = "payload"
    private const val KEY_ACTION_ID = "actionId"
    private const val KEY_CALL_ID = "callId"
    private const val KEY_EXPIRES_AT = "expiresAt"

    fun persist(
        context: Context,
        payload: String,
        actionId: String,
        callId: String,
        expiresAt: Long,
    ) {
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_PAYLOAD, payload)
            .putString(KEY_ACTION_ID, actionId)
            .putString(KEY_CALL_ID, callId)
            .putLong(KEY_EXPIRES_AT, expiresAt)
            .commit()
    }

    fun read(context: Context): Map<String, Any>? {
        val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
        val payload = preferences.getString(KEY_PAYLOAD, null)
        val actionId = preferences.getString(KEY_ACTION_ID, null)
        val callId = preferences.getString(KEY_CALL_ID, null)
        val expiresAt = preferences.getLong(KEY_EXPIRES_AT, 0L)
        if (payload == null || actionId == null || callId == null ||
            expiresAt < System.currentTimeMillis()
        ) {
            preferences.edit().clear().commit()
            return null
        }
        return mapOf(
            KEY_PAYLOAD to payload,
            KEY_ACTION_ID to actionId,
            KEY_CALL_ID to callId,
            KEY_EXPIRES_AT to expiresAt,
        )
    }

    fun acknowledge(context: Context, callId: String, actionId: String) {
        val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
        if (preferences.getString(KEY_CALL_ID, null) == callId &&
            preferences.getString(KEY_ACTION_ID, null) == actionId
        ) {
            preferences.edit().clear().commit()
        }
    }

    fun clearForCall(context: Context, callId: String?) {
        if (callId == null) return
        val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
        if (preferences.getString(KEY_CALL_ID, null) == callId) {
            preferences.edit().clear().commit()
        }
    }
}
