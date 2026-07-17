import 'package:flutter_test/flutter_test.dart';
import 'package:polycule/src/utils/matrix/voip/call_notification_manager.dart';

void main() {
  tearDown(() {
    CallNotificationManager.pendingIntent.value = null;
  });

  test('call notification IDs are deterministic and call-specific', () {
    expect(
      CallNotificationManager.notificationId('call-a'),
      CallNotificationManager.notificationId('call-a'),
    );
    expect(
      CallNotificationManager.notificationId('call-a'),
      isNot(CallNotificationManager.notificationId('call-b')),
    );
  });

  test('notification actions remain pending for matching session startup', () {
    final payload = CallNotificationManager.payload(
      clientIdentifier: 4,
      roomId: '!room:example.org',
      callId: 'call-id',
    );
    final intent = CallNotificationManager.receiveResponse(
      payload,
      actionId: CallNotificationManager.answerActionId,
    );

    expect(intent, isNotNull);
    expect(intent!.clientIdentifier, 4);
    expect(intent.roomId, '!room:example.org');
    expect(intent.callId, 'call-id');
    expect(intent.action, CallNotificationAction.answer);
    expect(CallNotificationManager.pendingIntent.value, same(intent));

    CallNotificationManager.clearPending(intent);
    expect(CallNotificationManager.pendingIntent.value, isNull);
  });
}
