import 'dart:async';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../../../utils/matrix/active_room_tracker.dart';
import '../../../../utils/matrix/neighboaring_event_extension.dart';
import '../../../../widgets/ascii_progress_indicator.dart';
import '../../../../widgets/matrix/scopes/event_scope.dart';
import '../../../../widgets/matrix/scopes/room_scope.dart';
import '../../../../widgets/matrix/scopes/timeline_scope.dart';
import '../../../room_list/room_list_position_tracker.dart';
import '../compose/compose_scope.dart';
import '../compose/message_input.dart';
import '../load_history_indicator.dart';
import '../timeline_event_tile.dart';
import '../timeline/unread_divider.dart';
import '../timeline/timeline_navigation_scope.dart';

class MembershipJoinView extends StatefulWidget {
  const MembershipJoinView({super.key});

  @override
  State<MembershipJoinView> createState() => _MembershipJoinViewState();
}

class _MembershipJoinViewState extends State<MembershipJoinView>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  Timeline? timeline;
  var listKey = GlobalKey<AnimatedListState>();
  final scrollController = ScrollController();
  final eventUpdateStreamController = StreamController<Event>.broadcast();
  final fullyReadMarkerKey = GlobalKey();
  final focusedEventKey = GlobalKey();
  bool _hasJumpedToUnread = false;
  bool _markingRead = false;
  bool _userScrollInProgress = false;
  int _receiptRevision = 0;
  String? _receiptFingerprint;
  StreamSubscription<SyncUpdate>? _syncSubscription;
  String? _unreadBoundaryEventId;
  String? _focusedEventId;
  late final AnimationController _highlightController;
  late final Animation<double> _highlightGlow;

  @override
  void initState() {
    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _highlightGlow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _highlightController,
        curve: Curves.easeInOut,
      ),
    );
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _getTimeline());
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timeline?.cancelSubscriptions();
    _syncSubscription?.cancel();
    eventUpdateStreamController.close();
    _highlightController.dispose();
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
      return const Center(child: AsciiProgressIndicator());
    }
    final room = RoomScope.of(context).room;
    final showTyping = room.summary.mJoinedMemberCount == 3 &&
        room.typingUsers.any((user) => user.id != room.client.userID);

    return TimelineNavigationScope(
      onNavigate: _navigateToEvent,
      child: ComposeScopeWidget(
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
                      RoomListPositionTracker.markInteraction(room);
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
                          return LoadHistoryIndicator(timeline: timeline);
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

    final isUnreadBoundary =
        event.eventId == _unreadBoundaryEventId && index > 0;

    Widget tile = EventScope(
      key: ValueKey(event.eventId),
      event: event,
      child: const TimelineEventTile(),
    );

    if (event.eventId == _focusedEventId) {
      final neon = Theme.of(context).colorScheme.primary;
      tile = AnimatedBuilder(
        key: focusedEventKey,
        animation: _highlightGlow,
        child: tile,
        builder: (context, child) => DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: neon.withValues(alpha: _highlightGlow.value * .8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: neon.withValues(alpha: _highlightGlow.value * .35),
                blurRadius: 12 * _highlightGlow.value,
                spreadRadius: 1.5 * _highlightGlow.value,
              ),
            ],
          ),
          child: child,
        ),
      );
    }

    if (isUnreadBoundary) {
      tile = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tile,
          UnreadDivider(key: fullyReadMarkerKey),
        ],
      );
    }

    return SizeTransition(sizeFactor: animation, child: tile);
  }

  Future<void> _getTimeline() async {
    final room = RoomScope.of(context).room;
    final fragment = GoRouterState.of(context).uri.fragment;
    _focusedEventId = fragment.isEmpty ? null : Uri.decodeComponent(fragment);
    ActiveRoomTracker.lifecycleState =
        WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
    String? initialReadEventId;
    if (room.isUnread) {
      final receiptEventId = room.receiptState.global.latestOwnReceipt?.eventId;
      initialReadEventId = receiptEventId?.isNotEmpty == true
          ? receiptEventId
          : room.fullyRead.isNotEmpty
              ? room.fullyRead
              : null;
    }
    _receiptFingerprint = _receiptStateFingerprint(room);
    _syncSubscription ??= room.client.onSync.stream.listen((_) {
      // Read receipts are ephemeral events: they update the room receipt
      // state without changing a timeline event, so the normal timeline
      // callbacks do not rebuild message read indicators.
      _updateReceiptRevision(room);
    });
    final timeline = await room.getTimeline(
      eventContextId: _focusedEventId,
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
    if (_focusedEventId == null) {
      unawaited(_markLatestRead(preserveUnreadMarker: true));
    } else {
      final focusedEventId = _focusedEventId!;
      final focusedIndex = timeline.events.indexWhere(
        (event) => event.eventId == focusedEventId,
      );
      if (focusedIndex >= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            unawaited(_focusAndHighlightEvent(focusedEventId, focusedIndex));
          }
        });
      }
    }

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
          if (markerY >= viewportHeight * .25 && markerY <= viewportHeight) {
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
      if (![
        EventTypes.Message,
        EventTypes.Sticker,
        EventTypes.Encrypted,
      ].contains(event.type)) {
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
      await room.setReadMarker(
        latestEventId,
        mRead: latestEventId,
        public: true,
      );
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

    final insertedEvent = timeline?.events.elementAtOrNull(insertID);
    if (insertedEvent?.senderId == RoomScope.of(context).room.client.userID) {
      RoomListPositionTracker.markInteraction(RoomScope.of(context).room);
    }
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

    listKey.currentState!.removeItem(index, (context, animation) {
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
    });
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

  String _receiptStateFingerprint(Room room) {
    final entries = room.receiptState.global.otherUsers.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries
        .map((entry) => '${entry.key}:${entry.value.eventId}:${entry.value.ts}')
        .join('|');
  }

  void _updateReceiptRevision(Room room) {
    final fingerprint = _receiptStateFingerprint(room);
    if (fingerprint == _receiptFingerprint) return;
    _receiptFingerprint = fingerprint;
    if (mounted) setState(() => _receiptRevision++);
  }

  Future<void> _navigateToEvent(String eventId) async {
    var timeline = this.timeline;
    if (timeline == null) return;
    var index = timeline.events.indexWhere((event) => event.eventId == eventId);
    if (index == -1) {
      final room = RoomScope.of(context).room;
      final contextualTimeline = await room.getTimeline(
        eventContextId: eventId,
        limit: 0,
        onInsert: _insertEvent,
        onRemove: _removeEvent,
        onChange: _changeEvent,
      );
      if (!mounted) {
        contextualTimeline.cancelSubscriptions();
        return;
      }
      timeline.cancelSubscriptions();
      timeline = contextualTimeline;
      index = timeline.events.indexWhere((event) => event.eventId == eventId);
      listKey = GlobalKey<AnimatedListState>();
      _unreadBoundaryEventId = null;
      setState(() => this.timeline = timeline);
    }
    if (index == -1) return;
    await _focusAndHighlightEvent(eventId, index);
  }

  Future<void> _focusAndHighlightEvent(String eventId, int index) async {
    _highlightController.reset();
    setState(() => _focusedEventId = eventId);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final target = focusedEventKey.currentContext;
    if (target != null) {
      if (!target.mounted) return;
      await Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: .35,
      );
    } else if (scrollController.hasClients) {
      scrollController.jumpTo(
        (index * 72.0)
            .clamp(0, scrollController.position.maxScrollExtent)
            .toDouble(),
      );
      await WidgetsBinding.instance.endOfFrame;
      final retriedTarget = focusedEventKey.currentContext;
      if (retriedTarget != null) {
        if (!retriedTarget.mounted) return;
        await Scrollable.ensureVisible(
          retriedTarget,
          duration: const Duration(milliseconds: 220),
          alignment: .35,
        );
      }
    }
    if (!mounted) return;
    await _highlightController.forward(from: 0);
    if (mounted && _focusedEventId == eventId) {
      setState(() => _focusedEventId = null);
    }
  }
}
