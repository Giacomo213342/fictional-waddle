// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';
import 'dart:js_util';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../router/extensions/matrix_deeplink_route.dart';
import '../../../../router/extensions/polycule_deeplink_route.dart';

dynamic createIdbFactory() {
  return getProperty(window, 'indexedDB');
}

Future<bool> persistStorage(AppLocalizations l10n) async {
  window.navigator.registerProtocolHandler(
    MatrixDeeplinkRoute.protocolName,
    '#/${MatrixDeeplinkRoute.protocolName}/%s',
    l10n.webUriHandlerTitle,
  );
  window.navigator.registerProtocolHandler(
    'web+${PolyculeDeeplinkRoute.protocolName}',
    '#/${PolyculeDeeplinkRoute.protocolName}/%s',
    l10n.webUriHandlerTitle,
  );

  return await window.navigator.storage?.persist() ?? false;
}
