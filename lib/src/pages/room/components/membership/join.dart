import 'dart:async';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../utils/matrix/active_room_tracker.dart';
import '../../../../utils/matrix/neighboaring_event_extension.dart';
import '../../../../widgets/ascii_progress_indicator.dart';
import '../../../../widgets/matrix/scopes/event_scope.dart';
import '../../../../widgets/matrix/scopes/room_scope.dart';
import '../../../../widgets/matrix/scopes/timeline_scope.dart';
import '../compose/compose_scope.dart';
import '../compose/message_input.dart';
import '../load_history_indicator.dart';
import '../timeline_event_tile.dart';
import '../timeline/unread_divider.dart';

class MembershipJoinView extends StatefulWidget {
  const MembershipJoinView({super.key});

  @override
  State<MembershipJoinView> createState() => _MembershipJoinViewState();
}

class _MembershipJoinViewState extends State<MembershipJoinView>
    with WidgetsBindingObserver {
  Timeline? timeline;
  final listKey = GlobalKey<AnimatedListState>();
  final scrollController = ScrollController();
  final eventUpdateStreamController = StreamController<Event>.broadcast();
  final fullyReadMarkerKey = GlobalKey();
  bool _hasJumpedToUnread = false;
  bool _markingRead = false;
  bool _userScrollInProgress = false;
  int _receiptRevision = 0;
  StreamSubscription<String>? _roomUpdateSubscription;
  StreamSubscription<SyncUpdate>? _syncSubscription;
  String? _unreadBoundaryEventId;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _getTimeline());
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timeline?.cancelSubscriptions();
    _roomUpdateSubscription?.cancel();
    _syncSubscription?.cancel();
    eventUpdateStreamController.close();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ActiveRoomTracker.lifecycleState = state;
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
    final showTyping = room.summary.mJoinedMemberCount == 3 &&
        room.typingUsers.any((user) => user.id != room.client.userID);

    return ComposeScopeWidget(
      child: TimelineScope(
        timeline: timeline,
        eventChangeStream: eventUpdateStreamController.stream,
        revision: _receiptRevision,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification &&
                      notification.dragDetails != null) {
                    _userScrollInProgress = true;
                  } else if (notification is ScrollUpdateNotification &&
                      notification.dragDetails != null) {
                    _userScrollInProgress = true;
                  } else if (notification is ScrollEndNotification) {
                    final reachedBottom = notification.metrics.pixels <= 64;
                    if (_userScrollInProgress && reachedBottom) {
                      _markLatestRead();
                    }
                    _userScrollInProgress = false;
                  }
                  return false;
                },
                child: SelectionArea(
                  child: AnimatedList(
                    controller: scrollController,
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
            ),
            if (room.canSendDefaultMessages)
              SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 120),
                      alignment: Alignment.bottomCenter,
                      child: showTyping
                          ? Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                                bottom: 4,
                              ),
                              child: Text(
                                'typing...',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    MessageInput(onStartedTyping: _dismissUnreadMarker),
                  ],
                ),
              ),
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

    final room = RoomScope.of(context).room;
    final isUnreadBoundary = event.eventId == _unreadBoundaryEventId &&
        index > 0;

    Widget tile = EventScope(
      key: ValueKey(event.eventId),
      event: event,
      child: const TimelineEventTile(),
    );

    if (isUnreadBoundary) {
      tile = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tile,
          UnreadDivider(key: fullyReadMarkerKey),
        ],
      );
    }

    return SizeTransition(
      sizeFactor: animation,
      child: tile,
    );
  }

  Future<void> _getTimeline() async {
    final room = RoomScope.of(context).room;
    ActiveRoomTracker.lifecycleState =
        WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
    String? initialReadEventId;
    if (room.isUnread) {
      final receiptEventId =
          room.receiptState.global.latestOwnReceipt?.eventId;
      initialReadEventId = receiptEventId?.isNotEmpty == true
          ? receiptEventId
          : room.fullyRead.isNotEmpty
              ? room.fullyRead
              : null;
    }
    _roomUpdateSubscription ??= room.onUpdate.stream.listen((_) {
      if (mounted) setState(() => _receiptRevision++);
    });
    _syncSubscription ??= room.client.onSync.stream.listen((_) {
      // Read receipts are ephemeral events: they update the room receipt
      // state without changing a timeline event, so the normal timeline
      // callbacks do not rebuild message read indicators.
      if (mounted) setState(() => _receiptRevision++);
    });
    final timeline = await room.getTimeline(
      onInsert: _insertEvent,
      onRemove: _removeEvent,
      onChange: _changeEvent,
    );

    if (!mounted) {
      return;
    }
    _unreadBoundaryEventId = _resolveUnreadBoundary(
      timeline,
      initialReadEventId,
      room.client.userID,
    );
    setState(() {
      this.timeline = timeline;
    });
    unawaited(_markLatestRead(preserveUnreadMarker: true));

    if (!_hasJumpedToUnread) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || fullyReadMarkerKey.currentContext == null) return;
        _hasJumpedToUnread = true;
        final markerContext = fullyReadMarkerKey.currentContext!;
        final markerBox = markerContext.findRenderObject() as RenderBox?;
        final scrollable = Scrollable.maybeOf(markerContext);
        final viewportBox =
            scrollable?.context.findRenderObject() as RenderBox?;
        if (markerBox != null && viewportBox != null) {
          final markerY = markerBox.localToGlobal(Offset.zero).dy -
              viewportBox.localToGlobal(Offset.zero).dy;
          final viewportHeight = viewportBox.size.height;
          if (markerY >= viewportHeight * .25 &&
              markerY <= viewportHeight) {
            return;
          }
        }
        Scrollable.ensureVisible(
          markerContext,
          duration: const Duration(milliseconds: 300),
          alignment: 0.1, // Near the top
        );
      });
    }
  }

  String? _resolveUnreadBoundary(
    Timeline timeline,
    String? initialReadEventId,
    String? ownUserId,
  ) {
    if (initialReadEventId == null || ownUserId == null) return null;
    final readIndex = timeline.events.indexWhere(
      (event) => event.eventId == initialReadEventId,
    );
    if (readIndex < 0) return initialReadEventId;

    var boundaryEventId = initialReadEventId;
    // The timeline is reversed: lower indices are newer. Include every own
    // message after the receipt, stopping at the first incoming event.
    for (var index = readIndex - 1; index >= 0; index--) {
      final event = timeline.events[index];
      if (![EventTypes.Message, EventTypes.Sticker, EventTypes.Encrypted]
          .contains(event.type)) {
        continue;
      }
      if (event.senderId != ownUserId) break;
      boundaryEventId = event.eventId;
    }
    return boundaryEventId;
  }

  void _dismissUnreadMarker() {
    if (_unreadBoundaryEventId == null) return;
    setState(() => _unreadBoundaryEventId = null);
  }

  Future<void> _markLatestRead({bool preserveUnreadMarker = false}) async {
    final timeline = this.timeline;
    if (_markingRead || timeline == null || timeline.events.isEmpty) return;
    final room = RoomScope.of(context).room;
    final latestEventId = timeline.events.first.eventId;
    if (room.fullyRead == latestEventId && !room.isUnread) return;
    _markingRead = true;
    if (!preserveUnreadMarker) _unreadBoundaryEventId = null;
    if (mounted) setState(() {});
    try {
      await room.setReadMarker(latestEventId, mRead: latestEventId);
      if (room.isUnread) await room.markUnread(false);
      // The homeserver confirms these counters on the next sync. Update the
      // in-memory room immediately so the room list cannot retain stale UI.
      room.notificationCount = 0;
      room.highlightCount = 0;
      if (mounted) setState(() {});
    } finally {
      _markingRead = false;
    }
  }

  void _insertEvent(int insertID) {
    listKey.currentState?.insertItem(insertID);

    _notifyNeighboringEvents(insertID);
    if (insertID == 0 &&
        scrollController.hasClients &&
        scrollController.position.pixels <= 24) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _markLatestRead());
    }
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
