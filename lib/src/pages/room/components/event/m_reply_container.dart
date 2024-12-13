import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'components/reply_user_prefix.dart';
import 'm_room_message/m_text.dart';

class ReplyContainer extends StatelessWidget {
  const ReplyContainer({
    super.key,
    required this.replyEvent,
    required this.globalKeySuffix,
    required this.constraints,
  });

  final Event replyEvent;
  final BoxConstraints constraints;
  final String globalKeySuffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4.0,
        bottom: 4.0,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .secondaryContainer
              .withValues(alpha: .25),
          border: Border(
            left: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
              width: 2,
            ),
          ),
        ),
        child: DefaultTextStyle(
          style: DefaultTextStyle.of(context).style.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
          child: InkWell(
            onTap: () {},
            child: SelectionArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 4.0,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth - 86,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      ReplyUserPrefix(replyEvent: replyEvent),
                      const SizedBox(height: 4),
                      ClipRect(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 96),
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: const EdgeInsets.all(.0),
                              child: TextMessage(
                                event: replyEvent,
                                globalKeyRegistryKey:
                                    replyEvent.eventId + globalKeySuffix,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
