import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../widgets/matrix/scopes/event_scope.dart';
import '../../../../utils/matrix/call_event_summary.dart';
import 'components/reply_user_prefix.dart';
import 'event_fallback_text.dart';
import 'm_room_message_content.dart';

class QuotedEvent extends StatelessWidget {
  const QuotedEvent({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // for all attachments, show a fallback while for any other event, show text
    final event = EventScope.of(context).event;
    final content =
        event.hasAttachment || isMatrixCallSignalingEventType(event.type)
            ? const EventFallbackText()
            : const RoomMessageContent();
    final quote = Padding(
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
          child: _QuoteSelection(
            selectable: onTap == null,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
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
    if (onTap == null) {
      return quote;
    }
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: quote,
      ),
    );
  }
}

class _QuoteSelection extends StatelessWidget {
  const _QuoteSelection({required this.selectable, required this.child});

  final bool selectable;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      selectable ? SelectionArea(child: child) : child;
}
