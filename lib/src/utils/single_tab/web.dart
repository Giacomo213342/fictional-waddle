import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/widgets.dart';

import 'package:web/web.dart';
import 'package:web_multiple_tab_detector/web_multiple_tab_detector.dart';

import '../../../l10n/generated/app_localizations.dart';

Future<bool> ensureSingleTab() async {
  // handle OAuth2.0 redirects
  final uri = Uri.parse(window.location.href);

  if (uri.fragment.startsWith('state') ||
      uri.queryParameters.containsKey('loginToken')) {
    final bc = BroadcastChannel('oauth2redirect');
    // broadcast the location.href to main tab
    bc.postMessage(window.location.href.toJS);

    final l10n = await _getL10n();
    _displayStatus(l10n.webOAuthReceivedNotice);

    return false;
  }

  // ensure single tab
  WebMultipleTabDetector.register('polycule_multiple_tab_detector');

  if (!await WebMultipleTabDetector.isSingleTab()) {
    final l10n = await _getL10n();
    _displayStatus(l10n.webMultipleTabNotice);

    return false;
  }

  return true;
}

Future<AppLocalizations> _getL10n() async {
  final locale = WidgetsBinding.instance.platformDispatcher
          .computePlatformResolvedLocale(AppLocalizations.supportedLocales) ??
      const Locale('en');
  return await AppLocalizations.delegate.load(locale);
}

void _displayStatus(String status) {
  console.log('Web initialization halted: $status'.toJS);

  status = const HtmlEscape().convert(status)..replaceAll('\n', r'<br />');
  window.document.querySelector('#status-text')?.innerHTML = status.toJS;
}
