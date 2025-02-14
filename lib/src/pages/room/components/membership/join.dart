import 'dart:async';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../utils/matrix/neighboaring_event_extension.dart';
import '../../../../widgets/ascii_progress_indicator.dart';
import '../../../../widgets/matrix/scopes/event_scope.dart';
import '../../../../widgets/matrix/scopes/room_scope.dart';
import '../../../../widgets/matrix/scopes/timeline_scope.dart';
import '../compose/compose_scope.dart';
import '../compose/message_input.dart';
import '../load_history_indicator.dart';
import '../timeline_event_tile.dart';

class MembershipJoinView extends StatefulWidget {
  const MembershipJoinView({super.key});

  @override
  State<MembershipJoinView> createState() => _MembershipJoinViewState();
}

class _MembershipJoinViewState extends State<MembershipJoinView> {
  Timeline? timeline;
  final listKey = GlobalKey<AnimatedListState>();
  final eventUpdateStreamController = StreamController<Event>.broadcast();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _getTimeline());
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
    if (timeline == null || timeline.events.isEmpty) {
      return const Center(
        child: AsciiProgressIndicator(),
      );
    }
    final room = RoomScope.of(context).room;

    return ComposeScopeWidget(
      child: TimelineScope(
        timeline: timeline,
        eventChangeStream: eventUpdateStreamController.stream,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            if (room.canSendDefaultMessages) const MessageInput(),
          ],
        ),
      ),
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
      child: EventScope(
        key: ValueKey(event.eventId),
        event: event,
        child: const TimelineEventTile(),
      ),
    );
  }

  Future<void> _getTimeline() async {
    final room = RoomScope.of(context).room;
    final timeline = await room.getTimeline(
      onInsert: _insertEvent,
      onRemove: _removeEvent,
      onChange: _changeEvent,
    );

    if (!mounted) {
      return;
    }
    setState(() {
      this.timeline = timeline;
    });
  }

  void _insertEvent(int insertID) {
    listKey.currentState?.insertItem(insertID);

    _notifyNeighboringEvents(insertID);
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
    _notifyNeighboringEvents(index);

    listKey.currentState!.removeItem(
      index,
      (context, animation) {
        return Container();
        /*final oldWidget = widget.controller.eventKeyRegistry
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
        );*/
      },
    );
  }

  void _changeEvent(int index) {
    final timeline = this.timeline;
    if (timeline == null) {
      return;
    }
    final event = timeline.events.elementAtOrNull(index);
    if (event == null) {
      listKey.currentState?.removeItem(
        index,
        (context, animation) => SizedBox.fromSize(size: Size.zero),
        duration: Duration.zero,
      );
      listKey.currentState?.insertItem(index, duration: Duration.zero);
      return;
    }
    _notifyNeighboringEvents(index);
  }

  void _notifyNeighboringEvents(int index) {
    final timeline = this.timeline;
    if (timeline == null) {
      return;
    }
    final event = timeline.events.elementAtOrNull(index);
    if (event == null) {
      return;
    }

    eventUpdateStreamController.add(event);

    final previousEvent = timeline.getPreviousDisplayEvent(index);
    if (previousEvent != null) {
      eventUpdateStreamController.add(previousEvent);
    }
    final nextEvent = timeline.getNextDisplayEvent(index);
    if (nextEvent != null) {
      eventUpdateStreamController.add(nextEvent);
    }
  }
}
