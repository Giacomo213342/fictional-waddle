import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:matrix/matrix.dart';

import 'components/reply_user_prefix.dart';
import 'm_room_message_content.dart';

class ReplyContainer extends StatelessWidget {
  const ReplyContainer({
    super.key,
    required this.replyEvent,
    required this.replyToEventId,
    required this.constraints,
  });

  final Event replyEvent;
  final BoxConstraints constraints;
  final String replyToEventId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(.25),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 4.0,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 128,
                    maxWidth: constraints.maxWidth - 86,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ReplyUserPrefix(replyEvent: replyEvent),
                      IntrinsicHeight(
                        child: OverflowBox(
                          fit: OverflowBoxFit.deferToChild,
                          child: RoomMessageContent(
                            event: replyEvent,
                            replyToEventId: replyToEventId,
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
