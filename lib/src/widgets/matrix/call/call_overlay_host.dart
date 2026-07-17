import 'package:flutter/material.dart';

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
            if (call != null)
              Positioned.fill(
                child: CallView(
                  key: ValueKey(call.session.callId),
                  activeCall: call,
                ),
              ),
          ],
        ),
      );
}
