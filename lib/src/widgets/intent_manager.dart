import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_links/app_links.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matrix/matrix.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../pages/account_selector/account_selector.dart';
import '../pages/share_target/share_target.dart';
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

  // prevent from interpreting a deep link as share
  static final _shareCache = Cache<Uri>(const Duration(milliseconds: 200));

  static final sharedPayloadListener =
      ValueNotifier<SharedIntentPayload?>(null);
  static final notificationRouteListener = ValueNotifier<String?>(null);
  static final clientsReady = ValueNotifier<bool>(false);
  static int _nextSharePayloadId = 0;
  static ValueChanged<String>? _navigate;
  static String? _pendingRoute;

  final _shareIntentCache = Cache<String>(const Duration(seconds: 2));

  static Completer<OidcCallbackResponse>? oidcCallbackCompleter;
  static Completer<String>? legacySsoCallbackCompleter;

  static void attachNavigation(ValueChanged<String> navigate) {
    _navigate = navigate;
    final pendingRoute = _pendingRoute;
    if (pendingRoute == null) {
      return;
    }
    _pendingRoute = null;
    WidgetsBinding.instance.addPostFrameCallback((_) => navigate(pendingRoute));
  }

  static void _navigateTo(String route) {
    final navigate = _navigate;
    if (navigate == null) {
      _pendingRoute = route;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => navigate(route));
  }

  @override
  void initState() {
    _subscribeDeepLinks();
    _subscribeShareIntents();
    _handleLostData();
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
      // tiny workaround for OAuth2.0 on web
      if (kIsWeb) {
        _appLinkSubscription = listenWebBroadcastChannel().listen(
          _handleDeeplink,
        );
        return;
      }
      _appLinkSubscription = AppLinks().uriLinkStream.listen(_handleDeeplink);

      final initialLink = await AppLinks().getInitialLink();
      if (initialLink == null) {
        return;
      }
      _handleDeeplink(initialLink);
    } on MissingPluginException {
      Logs().d('package:app_links is not supported on his device.');
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
      _navigateTo(fragment);
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
        _navigateTo(AccountSelectorPage.makeRedirectRoute(mxid ?? link));
      }
      return;
    }
    if (uri.scheme == _kPolyculeUriScheme) {
      if (mounted) {
        _navigateTo(
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

    final fingerprint = shareIntentFingerprint(files);
    if (files.length == 1 &&
        (files.single.type == SharedMediaType.text ||
            files.single.type == SharedMediaType.url)) {
      unawaited(
        _handleTextShare(
          files.single.path,
          fingerprint: fingerprint,
        ),
      );
      return;
    }
    if (_shareIntentCache.data == fingerprint) {
      Logs().v('Ignoring a duplicate share intent delivery.');
      return;
    }
    _shareIntentCache.data = fingerprint;

    final payload = sharedIntentPayloadFromFiles(
      files,
      id: _nextSharePayloadId++,
    );
    if (payload == null) {
      return;
    }

    sharedPayloadListener.value = payload;

    if (!mounted) {
      return;
    }
    _navigateTo(ShareTargetPage.routeName);
  }

  static Future<void> claimShareIntent() async {
    sharedPayloadListener.value = null;

    if (kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) {
      return;
    }
    await ReceiveSharingIntent.instance.reset();
  }

  Future<void> _handleTextShare(
    String? text, {
    required String fingerprint,
  }) async {
    if (text == null) {
      return;
    }
    // prevent from interpreting a deep link as share
    await Future.delayed(const Duration(milliseconds: 50));
    if (_shareCache.data == Uri.tryParse(text)) {
      Logs().v('Shared text was already handled as deep-link.');
      return;
    }
    if (_shareIntentCache.data == fingerprint) {
      Logs().v('Ignoring a duplicate text share intent delivery.');
      return;
    }
    _shareIntentCache.data = fingerprint;
    sharedPayloadListener.value = SharedIntentPayload(
      id: _nextSharePayloadId++,
      files: const [],
      text: text,
    );

    if (!mounted) {
      return;
    }
    _navigateTo(ShareTargetPage.routeName);
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

    sharedPayloadListener.value = SharedIntentPayload(
      id: _nextSharePayloadId++,
      files: files,
    );

    if (!mounted) {
      return;
    }
    _navigateTo(ShareTargetPage.routeName);
  }

  static void selectShareDestination({
    required String clientName,
    required String roomId,
  }) {
    final payload = sharedPayloadListener.value;
    if (payload == null) {
      return;
    }
    sharedPayloadListener.value = payload.copyWithDestination(
      clientName: clientName,
      roomId: roomId,
    );
  }

  static void clearShareDestination() {
    final payload = sharedPayloadListener.value;
    if (payload == null || payload.roomId == null) {
      return;
    }
    sharedPayloadListener.value = payload.copyWithDestination();
  }
}

@immutable
class SharedIntentPayload {
  const SharedIntentPayload({
    required this.id,
    required this.files,
    this.text,
    this.clientName,
    this.roomId,
  });

  final int id;
  final List<XFile> files;
  final String? text;
  final String? clientName;
  final String? roomId;

  bool get hasFiles => files.isNotEmpty;

  SharedIntentPayload copyWithDestination({
    String? clientName,
    String? roomId,
  }) =>
      SharedIntentPayload(
        id: id,
        files: files,
        text: text,
        clientName: clientName,
        roomId: roomId,
      );
}

SharedIntentPayload? sharedIntentPayloadFromFiles(
  Iterable<SharedMediaFile> sharedFiles, {
  required int id,
}) {
  final files = sharedFiles.toList(growable: false);
  final sharedText = files
      .where(
        (file) =>
            file.type == SharedMediaType.text ||
            file.type == SharedMediaType.url,
      )
      .map((file) => file.path.trim())
      .where((text) => text.isNotEmpty)
      .join('\n');
  final message = files
      .map((file) => file.message?.trim())
      .whereType<String>()
      .where((text) => text.isNotEmpty)
      .firstOrNull;
  final xfiles = files
      .where(
        (file) =>
            file.type != SharedMediaType.text &&
            file.type != SharedMediaType.url,
      )
      .map(
        (file) => XFile(
          file.path,
          mimeType: file.mimeType,
        ),
      )
      .toList(growable: false);
  final text = [message, sharedText]
      .whereType<String>()
      .where((value) => value.isNotEmpty)
      .join('\n');
  if (xfiles.isEmpty && text.isEmpty) {
    return null;
  }
  return SharedIntentPayload(
    id: id,
    files: xfiles,
    text: text.isEmpty ? null : text,
  );
}

String shareIntentFingerprint(Iterable<SharedMediaFile> files) => files
    .map(
      (file) => [
        file.type.value,
        file.path,
        file.mimeType ?? '',
        file.message ?? '',
      ].join('\u0000'),
    )
    .join('\u0001');

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
