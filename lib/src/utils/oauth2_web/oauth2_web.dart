import 'dart:async';
import 'dart:js_interop';

import 'package:matrix/matrix.dart';
import 'package:web/web.dart';

final _controller = StreamController<Uri>.broadcast();
BroadcastChannel? _broadcast;

Stream<Uri> listenWebBroadcastChannel() {
  _broadcast ??= BroadcastChannel('oauth2redirect')
    ..onmessage = ((MessageEvent? event) {
      final data = event?.data;
      if (data.isDefinedAndNotNull) {
        Logs().v('Received OAuth2.0 redirect.');
        _controller.add(Uri.parse(data.toString()));
      }
    }).toJS;
  return _controller.stream;
}

bool get isWebHostedOrigin =>
    window.location.protocol == 'https:' &&
    window.location.host != 'localhost' &&
    window.location.host.startsWith('localhost:');

Uri get webHostedOrigin =>
    Uri.parse(window.location.origin).resolve(window.location.pathname);
