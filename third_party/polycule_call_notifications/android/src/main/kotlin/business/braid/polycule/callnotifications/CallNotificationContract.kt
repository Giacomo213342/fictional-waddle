package business.braid.polycule.callnotifications

internal object CallNotificationContract {
    const val CHANNEL_ID = "polycule.incoming_calls.v5"
    const val ACTIVE_CHANNEL_ID = "polycule.active_calls.v2"
    const val ACTION_CLOSE_SURFACE =
        "business.braid.polycule.callnotifications.CLOSE_SURFACE"

    const val EXTRA_NOTIFICATION_ID = "notificationId"
    const val EXTRA_PAYLOAD = "payload"
    const val EXTRA_ACTION_ID = "actionId"
    const val EXTRA_CANCEL_NOTIFICATION = "cancelNotification"
    const val EXTRA_CALL_ID = "polycule.callId"
    const val EXTRA_CALLER_NAME = "polycule.callerName"
    const val EXTRA_VIDEO = "polycule.video"
    const val EXTRA_SELECTED_ACTION = "polycule.selectedAction"
    const val EXTRA_EXPIRES_AT = "polycule.expiresAt"

    const val SELECT_NOTIFICATION = "SELECT_NOTIFICATION"
    const val SELECT_FOREGROUND_NOTIFICATION = "SELECT_FOREGROUND_NOTIFICATION"
}
