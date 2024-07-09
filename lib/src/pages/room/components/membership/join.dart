import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../utils/matrix/neighboaring_event_extension.dart';
import '../../../../widgets/ascii_progress_indicator.dart';
import '../../room.dart';
import '../event/compose/message_input.dart';
import '../load_history_indicator.dart';
import '../timeline_event_tile.dart';

class MembershipJoinView extends StatefulWidget {
  const MembershipJoinView({
    super.key,
    required this.controller,
    required this.room,
  });

  final RoomController controller;
  final Room room;

  @override
  State<MembershipJoinView> createState() => _MembershipJoinViewState();
}

class _MembershipJoinViewState extends State<MembershipJoinView> {
  Timeline? timeline;
  final GlobalKey<AnimatedListState> listKey = GlobalKey();

  @override
  void initState() {
    _getTimeline();
    super.initState();
  }

  @override
  void dispose() {
    timeline?.cancelSubscriptions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeline = this.timeline;
    if (timeline == null) {
      return const Center(
        child: AsciiProgressIndicator(),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SelectionArea(
            child: AnimatedList(
              shrinkWrap: true,
              key: listKey,
              reverse: true,
              initialItemCount: timeline.events.length + 1,
              itemBuilder: (context, index, animation) {
                if (index == timeline.events.length) {
                  return LoadHistoryIndicator(
                    timeline: timeline,
                  );
                }

                final nextEvent = timeline.getNextDisplayEvent(index);
                final previousEvent = timeline.getPreviousDisplayEvent(index);
                final event = timeline.events[index].getDisplayEvent(timeline);

                return SizeTransition(
                  sizeFactor: animation,
                  child: TimelineEventTile(
                    key: widget.controller.eventKeyRegistry[index] ??=
                        GlobalKey<TimelineEventTileState>(),
                    event: event,
                    previousEvent: previousEvent,
                    nextEvent: nextEvent,
                    room: widget.room,
                    controller: widget.controller,
                    timeline: timeline,
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.room.canSendDefaultMessages)
          MessageInput(controller: widget.controller),
      ],
    );
  }

  Future<void> _getTimeline() async {
    final timeline = await widget.room.getTimeline(
      onInsert: _insertEvent,
      onRemove: _removeEvent,
      onChange: _changeEvent,
    );

    setState(() {
      this.timeline = timeline;
    });
  }

  void _insertEvent(int insertID) {
    listKey.currentState?.insertItem(insertID);
  }

  void _removeEvent(int index) {
    final timeline = this.timeline;
    if (timeline == null) {
      return;
    }
    listKey.currentState!.removeItem(
      index,
      (context, animation) {
        final nextEvent = widget.controller.eventKeyRegistry[index]
                ?.currentState?.widget.nextEvent ??
            timeline.getNextDisplayEvent(index);
        final previousEvent = widget.controller.eventKeyRegistry[index]
                ?.currentState?.widget.previousEvent ??
            timeline.getPreviousDisplayEvent(index);
        final event = widget.controller.eventKeyRegistry[index]?.currentState
                ?.widget.event ??
            timeline.events[index].getDisplayEvent(timeline);

        return SizeTransition(
          sizeFactor: animation,
          child: TimelineEventTile(
            key: widget.controller.eventKeyRegistry[index] ??=
                GlobalKey<TimelineEventTileState>(),
            event: event,
            previousEvent: previousEvent,
            nextEvent: nextEvent,
            room: widget.room,
            controller: widget.controller,
            timeline: timeline,
          ),
        );
      },
    );
  }

  void _changeEvent(int index) {
    listKey.currentState?.insertItem(index, duration: Duration.zero);
    listKey.currentState?.removeItem(
      index,
      (context, animation) {
        return Container();
      },
      duration: Duration.zero,
    );

    widget.controller.eventKeyRegistry[index]?.currentState;
  }
}
