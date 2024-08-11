import 'dart:typed_data';

import 'package:matrix/matrix.dart';
import 'package:unifiedpush/unifiedpush.dart';

class PushManager {
  PushManager(this.client);

  final Client client;

  String get instance => client.clientName;

  String? endpoint;

  Future<void> initialize() async {
    await UnifiedPush.initialize(
      onNewEndpoint: onNewEndpoint,
      onRegistrationFailed: onRegistrationFailed,
      onUnregistered: onUnregistered,
      onMessage: onMessage,
    );
  }

  void onNewEndpoint(String endpoint, String instance) {
    if (instance != this.instance) {
      return;
    }
    // You should send the endpoint to your application server
    // and sync for missing notifications.
    this.endpoint = endpoint;
  }

  void onRegistrationFailed(String instance) {
    if (instance != this.instance) {
      return;
    }
  }

  void onUnregistered(String instance) {
    if (instance != this.instance) {
      return;
    }
  }

  void onMessage(Uint8List message, String instance) {
    if (instance != this.instance) {
      return;
    }
  }
}
