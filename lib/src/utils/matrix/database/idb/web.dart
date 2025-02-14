import 'dart:js_interop';

import 'package:web/web.dart';

import '../../../../router/extensions/matrix_deeplink_route.dart';
import '../../../../router/extensions/polycule_deeplink_route.dart';

dynamic createIdbFactory() {
  return window.indexedDB;
}

Future<bool> persistStorage() async {
  window.navigator.registerProtocolHandler(
    MatrixDeeplinkRoute.protocolName,
    '#/${MatrixDeeplinkRoute.protocolName}/%s',
  );
  window.navigator.registerProtocolHandler(
    'web+${PolyculeDeeplinkRoute.protocolName}',
    '#/${PolyculeDeeplinkRoute.protocolName}/%s',
  );

  return window.navigator.storage.persist().toDart.then((b) => b.toDart);
}
