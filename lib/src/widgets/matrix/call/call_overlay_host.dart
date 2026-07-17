import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import '../../../utils/matrix/voip/polycule_call_coordinator.dart';
import 'call_view.dart';

class CallOverlayHost extends StatelessWidget {
  const CallOverlayHost({
    super.key,
    required this.coordinator,
    required this.child,
  });

  final PolyculeCallCoordinator coordinator;
  final Widget child;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: coordinator.activeCall,
        builder: (context, call, _) => Stack(
          children: [
            child,
            if (call != null &&
                !call.visible &&
                coordinator.isAwaitingAnswer(call.session))
              Positioned(
                left: 10,
                right: 10,
                top: MediaQuery.paddingOf(context).top + 8,
                child: IncomingCallBanner(
                  callerName: coordinator.peerName(call.session),
                  video: call.session.type == CallType.kVideo,
                  onOpen: coordinator.showActiveCall,
                  onAnswer: () => unawaited(coordinator.answerActiveCall()),
                  onDecline: () => unawaited(coordinator.declineActiveCall()),
                ),
              ),
            if (call != null && call.visible)
              Positioned.fill(
                child: CallView(
                  key: ValueKey(call.session.callId),
                  activeCall: call,
                  onMinimize: coordinator.minimizeActiveCall,
                ),
              ),
          ],
        ),
      );
}

class IncomingCallBanner extends StatelessWidget {
  const IncomingCallBanner({
    super.key,
    required this.callerName,
    required this.video,
    required this.onOpen,
    required this.onAnswer,
    required this.onDecline,
  });

  final String callerName;
  final bool video;
  final VoidCallback onOpen;
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
