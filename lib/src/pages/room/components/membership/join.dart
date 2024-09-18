import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../utils/matrix/neighboaring_event_extension.dart';
import '../../../../widgets/ascii_progress_indicator.dart';
import '../../room.dart';
import '../compose/message_input.dart';
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
                return buildTransitionedTile(
                  animation: animation,
                  index: index,
                  timeline: timeline,
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

  Widget buildTransitionedTile({
    required Animation<double> animation,
    required int index,
    required Timeline timeline,
    Event? event,
    Event? previousEvent,
    Event? nextEvent,
  }) {
    nextEvent ??= timeline.getNextDisplayEvent(index);
    previousEvent ??= timeline.getPreviousDisplayEvent(index);
    event ??= timeline.events[index];

    return SizeTransition(
      sizeFactor: animation,
      child: TimelineEventTile(
        key: widget.controller.eventKeyRegistry[event.eventId] ??=
            GlobalKey<TimelineEventTileState>(),
        event: event,
        previousEvent: previousEvent,
        nextEvent: nextEvent,
        room: widget.room,
        controller: widget.controller,
        timeline: timeline,
      ),
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
    final event = timeline.events.elementAtOrNull(index);
    if (event == null) {
      return;
    }

    listKey.currentState!.removeItem(
      index,
      (context, animation) {
        final oldWidget = widget.controller.eventKeyRegistry
            .remove(event.eventId)
            ?.currentState
            ?.widget;

        final nextEvent = oldWidget?.nextEvent;
        final previousEvent = oldWidget?.previousEvent;
        final oldEvent = oldWidget?.event;

        return buildTransitionedTile(
          animation: animation,
          index: index,
          timeline: timeline,
          event: oldEvent,
          previousEvent: previousEvent,
          nextEvent: nextEvent,
        );
      },
    );
    widget.controller.eventKeyRegistry.remove(event.eventId);
  }

  void _changeEvent(int index) {
    final timeline = this.timeline;
    if (timeline == null) {
      return;
    }
    final event = timeline.events.elementAtOrNull(index);
    if (event == null) {
      return;
    }

    final state =
        widget.controller.eventKeyRegistry[event.eventId]?.currentState;
    if (state != null) {
      final previousEvent = timeline.getPreviousDisplayEvent(index);
      final nextEvent = timeline.getNextDisplayEvent(index);
      state.updateEvent(
        event: event,
        previousEvent: previousEvent,
        nextEvent: nextEvent,
      );
      if (previousEvent != null) {
        widget.controller.eventKeyRegistry[previousEvent.eventId]?.currentState
            ?.updateEvent(
          nextEvent: event,
        );
      }
      if (nextEvent != null) {
        widget.controller.eventKeyRegistry[nextEvent.eventId]?.currentState
            ?.updateEvent(
          previousEvent: event,
        );
      }
    } else {
      listKey.currentState?.removeItem(
        index,
        (context, animation) => SizedBox.fromSize(size: Size.zero),
        duration: Duration.zero,
      );
      listKey.currentState?.insertItem(index, duration: Duration.zero);
    }
  }
}
