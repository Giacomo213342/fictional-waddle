import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matrix/matrix.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../pages/account_selector/account_selector.dart';
import '../router/extensions/polycule_deeplink_route.dart';
import '../utils/matrix_to_extension.dart';
import '../utils/oauth2_web/oauth2.dart';

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
  VoidCallback? _notificationRouteCallback;

  // prevent from interpreting a deep link as share
  static final _shareCache = Cache<Uri>(const Duration(milliseconds: 200));

  static final sharedTextListener = ValueNotifier<String?>(null);
  static final sharedFilesListener = ValueNotifier<List<XFile>?>(null);
  static final notificationRouteListener = ValueNotifier<String?>(null);

  static Completer<OidcCallbackResponse>? oidcCallbackCompleter;
  static Completer<String>? legacySsoCallbackCompleter;

  @override
  void initState() {
    _notificationRouteCallback = _handleNotificationRoute;
    notificationRouteListener.addListener(_notificationRouteCallback!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNotificationRoute();
    });
    _subscribeDeepLinks();
    _subscribeShareIntents();
    _handleLostData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    if (_notificationRouteCallback != null) {
      notificationRouteListener.removeListener(_notificationRouteCallback!);
    }
    _appLinkSubscription?.cancel();
    _shareIntentSubscription?.cancel();
    _shareTextSubscription?.cancel();
    super.dispose();
  }

  void _handleNotificationRoute() {
    final route = notificationRouteListener.value;
    if (!mounted || route == null) return;
    notificationRouteListener.value = null;
    context.go(route);
  }

  Future<void> _subscribeDeepLinks() async {
    try {
      // tiny workaround for OAuth2.0 on web
      if (kIsWeb) {
        _appLinkSubscription =
            listenWebBroadcastChannel().listen(_handleDeeplink);
        return;
      }
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
    // prevent from interpreting a deep link as share
    _shareCache.data = uri;

    final fragment = Uri.decodeComponent(uri.fragment);
    final segments = uri.pathSegments;

    // handle oauth2redirect
    final isWebOAuth2Redirect = kIsWeb &&
        // native OIDC
        (uri.fragment.startsWith('state=') ||
            // legacy SSO
            uri.queryParameters.containsKey('loginToken'));
    final isNativeOAuth2Redirect = !kIsWeb &&
        uri.scheme == 'im.polycule' &&
        segments.isNotEmpty &&
        segments.first == 'oauth2redirect';

    if (isWebOAuth2Redirect || isNativeOAuth2Redirect) {
      // ensure it's not legacy SSO
      if (!uri.queryParameters.containsKey('loginToken')) {
        oidcCallbackCompleter ??= Completer<OidcCallbackResponse>();
        oidcCallbackCompleter?.complete(
          OidcCallbackResponse.parse(
            uri.toString(),
            kIsWeb ? 'fragment' : 'query',
          ),
        );
      } else {
        legacySsoCallbackCompleter ??= Completer<String>();
        legacySsoCallbackCompleter?.complete(uri.queryParameters['loginToken']);
      }
      return;
    }

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

    if (identifier != null || uri.scheme == 'io.element.call') {
      final mxid = identifier?.toMatrixToUrl();

      if (mounted) {
        context.go(AccountSelectorPage.makeRedirectRoute(mxid ?? link));
      }
      return;
    }
    if (uri.scheme == _kPolyculeUriScheme) {
      if (mounted) {
        context.go(
          '${PolyculeDeeplinkRoute.routeName}/${Uri.encodeComponent(link)}',
        );
      }
      return;
    }
  }

  Future<void> _subscribeShareIntents() async {
    if (kIsWeb) {
      return;
    }
    try {
      if (!Platform.isIOS && !Platform.isAndroid) {
        return;
      }
      _shareIntentSubscription = ReceiveSharingIntent.instance
          .getMediaStream()
          .listen(_handleShareIntent);

      final initialShareIntent =
          await ReceiveSharingIntent.instance.getInitialMedia();

      _handleShareIntent(initialShareIntent);
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
    if (files.length == 1 &&
        [SharedMediaType.text, SharedMediaType.url].contains(
          files.single.type,
        )) {
      _handleTextShare(files.single.path);
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

  static Future<void> claimShareIntent() async {
    // first empty both share listeners
    sharedTextListener.value = null;
    sharedFilesListener.value = null;

    if (kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) {
      return;
    }
    await ReceiveSharingIntent.instance.reset();
  }

  Future<void> _handleTextShare(String? text) async {
    if (text == null) {
      return;
    }
    // prevent from interpreting a deep link as share
    await Future.delayed(const Duration(milliseconds: 50));
    if (_shareCache.data == Uri.tryParse(text)) {
      Logs().v('Shared text was already handled as deep-link.');
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

  Future<void> _handleLostData() async {
    List<XFile>? files;

    try {
      final picker = ImagePicker();

      final response = await picker.retrieveLostData();
      if (response.isEmpty) {
        return;
      }
      files = response.files;
    } on UnimplementedError catch (_) {}

    if (files == null || files.isEmpty) {
      return;
    }

    // first empty both share listeners
    sharedTextListener.value = null;
    sharedFilesListener.value = null;

    sharedFilesListener.value = files;

    if (!mounted) {
      return;
    }
    context.go(AccountSelectorPage.makeRedirectRoute('/'));
  }
}

class Cache<T> {
  Cache(this.timeout);

  final Duration timeout;

  Timer? _timer;
  T? _data;

  T? get data => _data;

  set data(T? data) {
    _data = data;
    _timer?.cancel();
    _timer = Timer(timeout, _resetCache);
  }

  void _resetCache() {
    _data = null;
  }
}
