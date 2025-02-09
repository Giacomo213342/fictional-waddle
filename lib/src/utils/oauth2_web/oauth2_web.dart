import 'dart:async';
import 'dart:js_interop';

import 'package:matrix/matrix.dart';
import 'package:web/web.dart';

Stream<Uri> listenWebBroadcastChannel() {
  final controller = StreamController<Uri>.broadcast();
  final bc = BroadcastChannel('oauth2redirect');
  bc.onmessage = ((String? event) {
    if (event is String) {
      Logs().v('Received OAuth2.0 redirect.');
      controller.add(Uri.parse(event));
    }
  }).toJS;
  return controller.stream;
}
