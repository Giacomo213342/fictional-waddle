import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../widgets/matrix/scopes/event_scope.dart';
import 'components/reply_user_prefix.dart';
import 'event_fallback_text.dart';
import 'm_room_message_content.dart';

class QuotedEvent extends StatelessWidget {
  const QuotedEvent({super.key});

  @override
  Widget build(BuildContext context) {
    // for all attachments, show a fallback while for any other event, show text
    final content = EventScope.of(context).event.hasAttachment
        ? const EventFallbackText()
        : const RoomMessageContent();
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
          child: SelectionArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 4.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const ReplyUserPrefix(),
                  const SizedBox(height: 4),
                  ClipRect(
                    child: OverflowBox(
                      maxHeight: 96,
                      fit: OverflowBoxFit.deferToChild,
                      alignment: Alignment.topLeft,
                      child: content,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
