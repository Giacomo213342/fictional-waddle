package business.braid.polycule.callnotifications

import android.content.Context

/**
 * Keeps duplicate UnifiedPush deliveries from extending the same ringing
 * invite. NotificationCompat's onlyAlertOnce then prevents a second alert.
 */
internal object IncomingCallStateStore {
    private const val PREFERENCES = "polycule.incoming_call_state"
    private const val KEY_CALL_ID = "callId"
    private const val KEY_EXPIRES_AT = "expiresAt"

    fun resolveExpiry(
        context: Context,
        callId: String,
        requestedExpiry: Long,
    ): Long {
        val preferences = context.getSharedPreferences(
            PREFERENCES,
            Context.MODE_PRIVATE,
        )
        val storedCallId = preferences.getString(KEY_CALL_ID, null)
        val storedExpiry = preferences.getLong(KEY_EXPIRES_AT, 0L)
        if (storedCallId == callId && storedExpiry > System.currentTimeMillis()) {
            return storedExpiry
        }
        preferences.edit()
            .putString(KEY_CALL_ID, callId)
            .putLong(KEY_EXPIRES_AT, requestedExpiry)
            .commit()
        return requestedExpiry
    }

    fun clear(context: Context, callId: String?) {
        if (callId == null) return
        val preferences = context.getSharedPreferences(
            PREFERENCES,
            Context.MODE_PRIVATE,
        )
        if (preferences.getString(KEY_CALL_ID, null) == callId) {
            preferences.edit().clear().commit()
        }
    }
}
