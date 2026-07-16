import 'package:flutter/material.dart';

import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/matrix/active_room_tracker.dart';
import '../../intent_manager.dart';
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
    super.dispose();
  }

  void _openPendingNotification() {
    final route = IntentManager.notificationRouteListener.value;
    if (!mounted || route == null || !IntentManager.clientsReady.value) return;

    final match = RegExp(r'^/client/(\d+)/rooms/[^/]+$').firstMatch(route);
    final clientIdentifier = int.tryParse(match?.group(1) ?? '');
    if (clientIdentifier == null ||
        ClientManager.of(context).getClientByIdentifier(clientIdentifier) ==
            null) {
      return;
    }

    GoRouter.of(context).go(route);
    IntentManager.notificationRouteListener.value = null;
  }

  @override
  Widget build(BuildContext context) {
    final activeRoomMatch =
        RegExp(r'^/client/\d+/rooms/([^/]+)$').firstMatch(widget.uri.path);
    ActiveRoomTracker.roomId = activeRoomMatch == null
        ? null
        : Uri.decodeComponent(activeRoomMatch.group(1)!);

    return Scaffold(
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
    );
  }
}
