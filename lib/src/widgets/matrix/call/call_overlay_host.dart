import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import '../../../utils/matrix/voip/polycule_call_coordinator.dart';
import 'call_view.dart';
import 'group_call_view.dart';

class CallOverlayHost extends StatefulWidget {
  const CallOverlayHost({
    super.key,
    required this.coordinator,
    required this.activeNavigatorKey,
    required this.child,
  });

  final PolyculeCallCoordinator coordinator;
  final GlobalKey<NavigatorState> activeNavigatorKey;
  final Widget child;

  @override
  State<CallOverlayHost> createState() => _CallOverlayHostState();
}

Route<void> buildPolyculeCallRoute(WidgetBuilder builder) => PageRouteBuilder(
      opaque: true,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 70),
      reverseTransitionDuration: const Duration(milliseconds: 60),
      pageBuilder: (context, _, __) => builder(context),
      transitionsBuilder: (context, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );

Future<void> showPolyculeCallRoute(
  BuildContext context,
  WidgetBuilder builder, {
  NavigatorState? navigator,
}) =>
    (navigator ?? Navigator.of(context)).push(
      buildPolyculeCallRoute(builder),
    );

class _CallOverlayHostState extends State<CallOverlayHost> {
  Route<void>? _callRoute;
  String? _callRouteId;
  String? _hiddenBannerCallId;

  PolyculeCallCoordinator get coordinator => widget.coordinator;

  @override
  void initState() {
    super.initState();
    coordinator.activeCall.addListener(_handleCallChanged);
    coordinator.activeGroupCall.addListener(_handleCallChanged);
    _scheduleRouteSync();
  }

  @override
  void didUpdateWidget(covariant CallOverlayHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.coordinator, coordinator)) {
      oldWidget.coordinator.activeCall.removeListener(_handleCallChanged);
      oldWidget.coordinator.activeGroupCall.removeListener(_handleCallChanged);
      coordinator.activeCall.addListener(_handleCallChanged);
      coordinator.activeGroupCall.addListener(_handleCallChanged);
      _scheduleRouteSync();
    } else if (!identical(
      oldWidget.activeNavigatorKey,
      widget.activeNavigatorKey,
    )) {
      _scheduleRouteSync();
    }
  }

  @override
  void dispose() {
    coordinator.activeCall.removeListener(_handleCallChanged);
    coordinator.activeGroupCall.removeListener(_handleCallChanged);
    super.dispose();
  }

  void _handleCallChanged() {
    final callId = _activeCallRouteId();
    if (_hiddenBannerCallId != null && _hiddenBannerCallId != callId) {
      _hiddenBannerCallId = null;
    }
    if (mounted) {
      setState(() {});
    }
    _scheduleRouteSync();
  }

  void _scheduleRouteSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncCallRoute();
      }
    });
  }

  void _syncCallRoute() {
    final peerCall = coordinator.activeCall.value;
    final groupCall = coordinator.activeGroupCall.value;
    final activeRouteId = _activeCallRouteId();
    final shouldShow =
        (peerCall?.visible ?? false) || (groupCall?.visible ?? false);
    final existing = _callRoute;

    if (!shouldShow) {
      if (existing != null && existing.isActive) {
        existing.navigator?.removeRoute(existing);
      }
      return;
    }

    if (existing != null) {
      if (_callRouteId == activeRouteId &&
          identical(
            existing.navigator,
            widget.activeNavigatorKey.currentState,
          ) &&
          existing.isActive) {
        return;
      }
      if (existing.isActive) {
        existing.navigator?.removeRoute(existing);
      }
      return;
    }

    final callId = activeRouteId!;
    final route = buildPolyculeCallRoute(
      (routeContext) => AnimatedBuilder(
        animation: coordinator.callState,
        builder: (context, _) {
          final currentPeer = coordinator.activeCall.value;
          final currentGroup = coordinator.activeGroupCall.value;
          if (currentPeer != null &&
              'peer:${currentPeer.session.callId}' == callId) {
            return CallView(
              key: ValueKey(callId),
              activeCall: currentPeer,
              onMinimize: () => Navigator.of(routeContext).maybePop(),
            );
          }
          if (currentGroup != null &&
              'group:${currentGroup.session.groupCallId}' == callId) {
            return GroupCallView(
              key: ValueKey(callId),
              activeCall: currentGroup,
              onMinimize: () => Navigator.of(routeContext).maybePop(),
            );
          }
          if (currentPeer == null && currentGroup == null) {
            return const Material(child: SizedBox.expand());
          }
          return const Material(child: SizedBox.expand());
        },
      ),
    );
    _callRoute = route;
    _callRouteId = callId;
    final navigator = widget.activeNavigatorKey.currentState;
    if (navigator == null) {
      _callRoute = null;
      _callRouteId = null;
      return;
    }
    final navigatorAtPush = navigator;
    navigator.push(route).whenComplete(() {
      if (!mounted || !identical(_callRoute, route)) {
        return;
      }
      _callRoute = null;
      _callRouteId = null;
      final currentPeer = coordinator.activeCall.value;
      final currentGroup = coordinator.activeGroupCall.value;
      final remainsVisible = currentPeer != null &&
              'peer:${currentPeer.session.callId}' == callId &&
              currentPeer.visible ||
          currentGroup != null &&
              'group:${currentGroup.session.groupCallId}' == callId &&
              currentGroup.visible;
      if (remainsVisible) {
        if (identical(
          navigatorAtPush,
          widget.activeNavigatorKey.currentState,
        )) {
          if (currentPeer != null &&
              'peer:${currentPeer.session.callId}' == callId) {
            coordinator.minimizeActiveCall();
          } else {
            coordinator.minimizeActiveGroupCall();
          }
        } else {
          _scheduleRouteSync();
        }
      } else {
        _scheduleRouteSync();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final peerCall = coordinator.activeCall.value;
    final groupCall = coordinator.activeGroupCall.value;
    final routeId = _activeCallRouteId();
    final minimized = peerCall != null && !peerCall.visible ||
        groupCall != null && !groupCall.visible;
    final bannerHidden = minimized && _hiddenBannerCallId == routeId;
    return Stack(
      children: [
        widget.child,
        if (minimized)
          Positioned(
            right: 10,
            top: MediaQuery.paddingOf(context).top + 8,
            child: bannerHidden
                ? _HiddenCallButton(
                    incoming: peerCall != null &&
                        coordinator.isAwaitingAnswer(peerCall.session),
                    onPressed: coordinator.showAnyActiveCall,
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: peerCall != null &&
                            coordinator.isAwaitingAnswer(peerCall.session)
                        ? IncomingCallBanner(
                            callerName: coordinator.peerName(peerCall.session),
                            video: peerCall.session.type == CallType.kVideo,
                            onOpen: coordinator.showAnyActiveCall,
                            onHide: () => setState(() {
                              _hiddenBannerCallId = routeId;
                            }),
                            onAnswer: () =>
                                unawaited(coordinator.answerActiveCall()),
                            onDecline: () =>
                                unawaited(coordinator.declineActiveCall()),
                          )
                        : ActiveCallBanner(
                            peerName: peerCall != null
                                ? coordinator.peerName(peerCall.session)
                                : coordinator.groupCallName(groupCall!.session),
                            status: peerCall != null
                                ? peerCall.blockingError ??
                                    _compactCallStatus(peerCall)
                                : groupCall!.blockingError ??
                                    _compactGroupCallStatus(groupCall),
                            onOpen: coordinator.showAnyActiveCall,
                            onHide: () => setState(() {
                              _hiddenBannerCallId = routeId;
                            }),
                            onHangup: () => unawaited(
                              peerCall != null
                                  ? coordinator.hangupActiveCall()
                                  : coordinator.leaveActiveGroupCall(),
                            ),
                          ),
                  ),
          ),
      ],
    );
  }

  String? _activeCallRouteId() {
    final peerCall = coordinator.activeCall.value;
    if (peerCall != null) {
      return 'peer:${peerCall.session.callId}';
    }
    final groupCall = coordinator.activeGroupCall.value;
    if (groupCall != null) {
      return 'group:${groupCall.session.groupCallId}';
    }
    return null;
  }
}

String _compactCallStatus(ActivePolyculeCall call) =>
    switch (call.session.state) {
      CallState.kConnected => 'Call in progress',
      CallState.kConnecting => call.connectionStatus ?? 'Connecting call…',
      CallState.kRinging => 'Calling…',
      _ => 'Active call',
    };

String _compactGroupCallStatus(ActivePolyculeGroupCall call) {
  final participants =
      call.session.participants.map((participant) => participant.userId).toSet()
        ..addAll(
          call.session.backend.userMediaStreams.map(
            (stream) => stream.participant.userId,
          ),
        );
  return '${participants.length} participant'
      '${participants.length == 1 ? '' : 's'}';
}

class ActiveCallBanner extends StatelessWidget {
  const ActiveCallBanner({
    super.key,
    required this.peerName,
    required this.status,
    required this.onOpen,
    required this.onHide,
    required this.onHangup,
  });

  final String peerName;
  final String status;
  final VoidCallback onOpen;
  final VoidCallback onHide;
  final VoidCallback onHangup;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colors.outlineVariant),
      ),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 7, 6, 7),
          child: Row(
            children: [
              const Icon(Icons.call_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      peerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              _BannerAction(
                tooltip: 'Hide',
                icon: Icons.close,
                color: colors.onSurfaceVariant,
                onPressed: onHide,
              ),
              _BannerAction(
                tooltip: 'Hang up',
                icon: Icons.call_end,
                color: colors.error,
                onPressed: onHangup,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IncomingCallBanner extends StatelessWidget {
  const IncomingCallBanner({
    super.key,
    required this.callerName,
    required this.video,
    required this.onOpen,
    required this.onHide,
    required this.onAnswer,
    required this.onDecline,
  });

  final String callerName;
  final bool video;
  final VoidCallback onOpen;
  final VoidCallback onHide;
  final VoidCallback onAnswer;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colors.outlineVariant),
      ),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 7, 6, 7),
          child: Row(
            children: [
              Icon(video ? Icons.videocam_outlined : Icons.call_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$callerName is calling you!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              _BannerAction(
                tooltip: 'Hide',
                icon: Icons.close,
                color: colors.onSurfaceVariant,
                onPressed: onHide,
              ),
              _BannerAction(
                tooltip: 'Decline',
                icon: Icons.call_end,
                color: colors.error,
                onPressed: onDecline,
              ),
              const SizedBox(width: 2),
              _BannerAction(
                tooltip: 'Answer',
                icon: Icons.call,
                color: colors.primary,
                onPressed: onAnswer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HiddenCallButton extends StatelessWidget {
  const _HiddenCallButton({required this.incoming, required this.onPressed});

  final bool incoming;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHigh,
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        tooltip: incoming ? 'Incoming call' : 'Active call',
        onPressed: onPressed,
        icon: Icon(
          incoming ? Icons.ring_volume_outlined : Icons.call_outlined,
          size: 19,
        ),
      ),
    );
  }
}

class _BannerAction extends StatelessWidget {
  const _BannerAction({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        style: IconButton.styleFrom(foregroundColor: color),
        onPressed: onPressed,
        icon: Icon(icon, size: 19),
      );
}
