import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import '../../../utils/matrix/voip/polycule_call_coordinator.dart';
import 'call_view.dart';

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
    _scheduleRouteSync();
  }

  @override
  void didUpdateWidget(covariant CallOverlayHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.coordinator, coordinator)) {
      oldWidget.coordinator.activeCall.removeListener(_handleCallChanged);
      coordinator.activeCall.addListener(_handleCallChanged);
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
    super.dispose();
  }

  void _handleCallChanged() {
    final callId = coordinator.activeCall.value?.session.callId;
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
    final active = coordinator.activeCall.value;
    final shouldShow = active != null && active.visible;
    final existing = _callRoute;

    if (!shouldShow) {
      if (existing != null && existing.isActive) {
        existing.navigator?.removeRoute(existing);
      }
      return;
    }

    if (existing != null) {
      if (_callRouteId == active.session.callId &&
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

    final callId = active.session.callId;
    final route = buildPolyculeCallRoute(
      (routeContext) => ValueListenableBuilder<ActivePolyculeCall?>(
        valueListenable: coordinator.activeCall,
        builder: (context, current, _) {
          if (current == null || current.session.callId != callId) {
            return const Material(child: SizedBox.expand());
          }
          return CallView(
            key: ValueKey(callId),
            activeCall: current,
            onMinimize: () => Navigator.of(routeContext).maybePop(),
          );
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
      final current = coordinator.activeCall.value;
      if (current != null &&
          current.session.callId == callId &&
          current.visible) {
        if (identical(
          navigatorAtPush,
          widget.activeNavigatorKey.currentState,
        )) {
          coordinator.minimizeActiveCall();
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
    final call = coordinator.activeCall.value;
    final bannerHidden = call != null &&
        !call.visible &&
        _hiddenBannerCallId == call.session.callId;
    return Stack(
      children: [
        widget.child,
        if (call != null && !call.visible)
          Positioned(
            right: 10,
            top: MediaQuery.paddingOf(context).top + 8,
            child: bannerHidden
                ? _HiddenCallButton(
                    incoming: coordinator.isAwaitingAnswer(call.session),
                    onPressed: coordinator.showActiveCall,
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: coordinator.isAwaitingAnswer(call.session)
                        ? IncomingCallBanner(
                            callerName: coordinator.peerName(call.session),
                            video: call.session.type == CallType.kVideo,
                            onOpen: coordinator.showActiveCall,
                            onHide: () => setState(() {
                              _hiddenBannerCallId = call.session.callId;
                            }),
                            onAnswer: () =>
                                unawaited(coordinator.answerActiveCall()),
                            onDecline: () =>
                                unawaited(coordinator.declineActiveCall()),
                          )
                        : ActiveCallBanner(
                            peerName: coordinator.peerName(call.session),
                            status:
                                call.blockingError ?? _compactCallStatus(call),
                            onOpen: coordinator.showActiveCall,
                            onHide: () => setState(() {
                              _hiddenBannerCallId = call.session.callId;
                            }),
                            onHangup: () =>
                                unawaited(coordinator.hangupActiveCall()),
                          ),
                  ),
          ),
      ],
    );
  }
}

String _compactCallStatus(ActivePolyculeCall call) =>
    switch (call.session.state) {
      CallState.kConnected => 'Call in progress',
      CallState.kConnecting => call.connectionStatus ?? 'Connecting call…',
      CallState.kRinging => 'Calling…',
      _ => 'Active call',
    };

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
