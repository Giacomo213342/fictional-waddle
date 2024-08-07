import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_links/app_links.dart';
import 'package:cross_file/cross_file.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:receive_sharing_intent_plus/receive_sharing_intent_plus.dart';

import '../pages/account_selector/account_selector.dart';
import '../router/extensions/polycule_deeplink_route.dart';
import '../utils/matrix_to_extension.dart';

const _kPolyculeUriScheme = 'web+polycule';

class IntentManagerWidget extends StatefulWidget {
  const IntentManagerWidget({super.key, required this.child});

  final Widget child;

  @override
  State<IntentManagerWidget> createState() => IntentManager();
}

class IntentManager extends State<IntentManagerWidget> {
  StreamSubscription<Uri>? _appLinkSubscription;

  StreamSubscription<List<SharedMediaFile>>? _shareIntentSubscription;
  StreamSubscription<String>? _shareTextSubscription;

  static final sharedTextListener = ValueNotifier<String?>(null);
  static final sharedFilesListener = ValueNotifier<List<XFile>?>(null);

  @override
  void initState() {
    _subscribeDeepLinks();
    _subscribeShareIntents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    _appLinkSubscription?.cancel();
    _shareIntentSubscription?.cancel();
    _shareTextSubscription?.cancel();
    super.dispose();
  }

  Future<void> _subscribeDeepLinks() async {
    try {
      _appLinkSubscription = AppLinks().uriLinkStream.listen(_handleDeeplink);

      final initialLink = await AppLinks().getInitialLink();
      if (initialLink == null) {
        return;
      }
      _handleDeeplink(initialLink);
    } on MissingPluginException {
      Logs().d(
        'package:app_links is not supported on his device.',
      );
    }
  }

  void _handleDeeplink(Uri uri) {
    String link = Uri.decodeComponent(uri.toString());
    final fragment = Uri.decodeComponent(uri.fragment);

    if (uri.scheme == 'https' && uri.host == 'polycule.im') {
      context.go(fragment);
    }
    if (uri.scheme == _kPolyculeUriScheme) {
      // check whether we got a matrix URL but as polycule deeplink
      link = link.replaceFirst(_kPolyculeUriScheme, 'matrix');
    }
    MatrixIdentifierStringExtensionResults? identifier =
        link.parseIdentifierIntoParts();

    // bug : the '$' often get lost in Android Intents
    if (identifier == null &&
        (fragment.split('/').elementAtOrNull(1)?.isValidMatrixId ?? false)) {
      final secondary = link.split('/').last;
      link = link.replaceFirst(secondary, '\$$secondary');
      identifier = link.parseIdentifierIntoParts();
    }

    if (identifier != null) {
      final mxid = identifier.toMatrixToUrl();

      if (mounted) {
        context.go(AccountSelectorPage.makeRedirectRoute(mxid));
      }
      return;
    }
    if (uri.scheme == _kPolyculeUriScheme) {
      if (mounted) {
        context.go(
          '${PolyculeDeeplinkRoute.routeName}/${Uri.encodeComponent(link)}',
        );
      }
    }
  }

  Future<void> _subscribeShareIntents() async {
    try {
      _shareIntentSubscription =
          ReceiveSharingIntentPlus.getMediaStream().listen(_handleShareIntent);
      _shareTextSubscription =
          ReceiveSharingIntentPlus.getTextStream().listen(_handleTextShare);

      final initialShareIntent =
          await ReceiveSharingIntentPlus.getInitialMedia();
      final initialShareText = await ReceiveSharingIntentPlus.getInitialText();

      _handleShareIntent(initialShareIntent);
      _handleTextShare(initialShareText);
    } on MissingPluginException {
      Logs().d(
        'package:receive_sharing_intent_plus is not supported on his device.',
      );
    }
  }

  void _handleShareIntent(List<SharedMediaFile> files) {
    if (files.isEmpty) {
      return;
    }

    // first empty both share listeners
    sharedTextListener.value = null;
    sharedFilesListener.value = null;

    final xfiles = files.map((file) => XFile(file.path)).toList();
    if (xfiles.isEmpty) {
      return;
    }

    sharedFilesListener.value = xfiles;

    if (!mounted) {
      return;
    }
    context.go(AccountSelectorPage.makeRedirectRoute('/'));
  }

  static void claimShareIntent() {
    // first empty both share listeners
    sharedTextListener.value = null;
    sharedFilesListener.value = null;

    return ReceiveSharingIntentPlus.reset();
  }

  void _handleTextShare(String? text) {
    if (text == null) {
      return;
    }
    // first empty both share listeners
    sharedTextListener.value = null;
    sharedFilesListener.value = null;

    sharedTextListener.value = text;

    if (!mounted) {
      return;
    }
    context.go(AccountSelectorPage.makeRedirectRoute('/'));
  }
}
