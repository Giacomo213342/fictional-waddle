import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../../pages/room_list/room_list_position_tracker.dart';
import '../../../utils/matrix/active_room_tracker.dart';
import '../../intent_manager.dart';
import '../scopes/client_scope.dart';
import 'client_manager.dart';
import 'components/top/keyboard_aware_top_bar.dart';

class ClientTabView extends StatefulWidget {
  const ClientTabView({super.key, required this.uri, required this.child});

  final Uri uri;
  final Widget child;

  @override
  State<ClientTabView> createState() => _ClientTabViewState();
}

class _ClientTabViewState extends State<ClientTabView> {
  late final VoidCallback _notificationRouteCallback;
  late final VoidCallback _clientsReadyCallback;
  StreamSubscription<SyncUpdate>? _notificationSyncSubscription;
  Client? _notificationSyncClient;
  String? _notificationSyncRoute;

  @override
  void initState() {
    super.initState();
    _notificationRouteCallback = _openPendingNotification;
    _clientsReadyCallback = _openPendingNotification;
    IntentManager.notificationRouteListener.addListener(
      _notificationRouteCallback,
    );
    IntentManager.clientsReady.addListener(_clientsReadyCallback);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openPendingNotification();
    });
  }

  @override
  void dispose() {
    IntentManager.notificationRouteListener.removeListener(
      _notificationRouteCallback,
    );
    IntentManager.clientsReady.removeListener(_clientsReadyCallback);
    unawaited(_notificationSyncSubscription?.cancel());
    super.dispose();
  }

  void _openPendingNotification() {
    final route = IntentManager.notificationRouteListener.value;
    if (!mounted) return;
    if (route == null) {
      _cancelNotificationSyncWatch();
      return;
    }
    if (!IntentManager.clientsReady.value) return;

    final match = RegExp(r'^/client/(\d+)/rooms/([^/]+)$').firstMatch(route);
    final clientIdentifier = int.tryParse(match?.group(1) ?? '');
    final encodedRoomId = match?.group(2);
    if (clientIdentifier == null || encodedRoomId == null) {
      IntentManager.notificationRouteListener.value = null;
      return;
    }

    final client =
        ClientManager.of(context).getClientByIdentifier(clientIdentifier);
    if (client == null) return;

    final roomId = Uri.decodeComponent(encodedRoomId);
    final initialSyncFinished = client.onSync.value != null;
    final roomAvailable = client.getRoomById(roomId) != null;
    if (!initialSyncFinished || !roomAvailable) {
      _watchNotificationClient(client, route);
      return;
    }

    _cancelNotificationSyncWatch();
    GoRouter.of(context).go(route);
    if (IntentManager.notificationRouteListener.value == route) {
      IntentManager.notificationRouteListener.value = null;
    }
  }

  void _watchNotificationClient(Client client, String route) {
    if (identical(_notificationSyncClient, client) &&
        _notificationSyncRoute == route) {
      return;
    }
    _cancelNotificationSyncWatch();
    _notificationSyncClient = client;
    _notificationSyncRoute = route;
    _notificationSyncSubscription = client.onSync.stream.listen(
      (_) => _openPendingNotification(),
      onError: (Object error, StackTrace stackTrace) {
        Logs().w(
          'Unable to wait for notification room sync.',
          error,
          stackTrace,
        );
      },
    );
  }

  void _cancelNotificationSyncWatch() {
    final subscription = _notificationSyncSubscription;
    _notificationSyncSubscription = null;
    _notificationSyncClient = null;
    _notificationSyncRoute = null;
    if (subscription != null) unawaited(subscription.cancel());
  }

  Future<bool> _handleBackButton() async {
    final roomMatch =
        RegExp(r'^/client/\d+/rooms/([^/]+)$').firstMatch(widget.uri.path);
    if (roomMatch == null) return false;

    final rootNavigator = Navigator.of(context, rootNavigator: true);
    if (rootNavigator.canPop()) {
      await rootNavigator.maybePop();
      return true;
    }

    final roomId = Uri.decodeComponent(roomMatch.group(1)!);
    final room = ClientScope.of(context).client.getRoomById(roomId);
    if (room != null) RoomListPositionTracker.prepareReturn(room);

    final uri = widget.uri;
    if (uri.fragment.isNotEmpty) {
      GoRouter.of(context).go(uri.replace(fragment: '').toString());
    } else {
      GoRouter.of(context).go(
        uri
            .replace(
              path: uri.path.substring(0, uri.path.lastIndexOf('/')),
              fragment: '',
            )
            .toString(),
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final activeRoomMatch =
        RegExp(r'^/client/\d+/rooms/([^/]+)$').firstMatch(widget.uri.path);
    ActiveRoomTracker.roomId = activeRoomMatch == null
        ? null
        : Uri.decodeComponent(activeRoomMatch.group(1)!);

    return BackButtonListener(
      onBackButtonPressed: _handleBackButton,
      child: Scaffold(
        body: AdaptiveLayout(
          transitionDuration: Duration.zero,
          body: SlotLayout(
            config: {
              Breakpoints.smallAndUp: SlotLayout.from(
                key: const Key('body'),
                builder: (context) => widget.child,
              ),
            },
          ),
          topNavigation: SlotLayout(
            config: {
              Breakpoints.mediumLargeAndUp: SlotLayout.from(
                key: const Key('top-app-bar'),
                builder: (context) {
                  return const KeyboardAwareTopBar();
                },
              ),
            },
          ),
        ),
      ),
    );
  }
}
