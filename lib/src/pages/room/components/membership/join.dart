import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../../../router/extensions/go_router_path_extension.dart';
import '../../../../utils/matrix/active_room_tracker.dart';
import '../../../../utils/matrix/is_display_event_extension.dart';
import '../../../../utils/matrix/neighboaring_event_extension.dart';
import '../../../../utils/matrix/poll_event.dart';
import '../../../../widgets/ascii_progress_indicator.dart';
import '../../../../widgets/matrix/scopes/event_scope.dart';
import '../../../../widgets/matrix/scopes/event_navigation_scope.dart';
import '../../../../widgets/matrix/scopes/poll_update_scope.dart';
import '../../../../widgets/matrix/scopes/room_scope.dart';
import '../../../../widgets/matrix/scopes/timeline_scope.dart';
import '../../../room_list/room_list_position_tracker.dart';
import '../../../room_list/components/plain_event_preview_text.dart';
import '../../room.dart';
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

@visibleForTesting
bool shouldShowLatestMessagesShortcut({
  required double pixels,
  required double viewportDimension,
}) =>
    pixels > max(160, viewportDimension * .65);

@visibleForTesting
double estimateReversedTimelineOffset({
  required int eventIndex,
  required int eventCount,
  required double maxScrollExtent,
}) {
  if (eventCount <= 1 || maxScrollExtent <= 0) return 0;
  return (maxScrollExtent * eventIndex / (eventCount - 1))
      .clamp(0, maxScrollExtent)
      .toDouble();
}

@visibleForTesting
const initialHistoryRevealDuration = Duration(milliseconds: 80);

@visibleForTesting
const initialUnreadMarkerAlignment = .43;

@visibleForTesting
Duration initialHistoryRevealDelay(int order) =>
    Duration(milliseconds: min(order, 8) * 10);

@visibleForTesting
String? resolveUnreadBoundaryEventId(
  List<Event> events,
  String? initialReadEventId,
  String? ownUserId,
) {
  if (initialReadEventId == null || ownUserId == null) return null;
  final readIndex = events.indexWhere(
    (event) => event.eventId == initialReadEventId,
  );
  if (readIndex < 0) return null;

  var boundaryEventId = initialReadEventId;
  // The timeline is reversed: lower indices are newer. Keep own messages
  // sent after the receipt above the divider, until the first incoming event.
  for (var index = readIndex - 1; index >= 0; index--) {
    final event = events[index];
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

@visibleForTesting
String? firstUnreadDisplayEventId(
  List<Event> events,
  String? boundaryEventId,
) {
  if (boundaryEventId == null) return null;
  final boundaryIndex = events.indexWhere(
    (event) => event.eventId == boundaryEventId,
  );
  if (boundaryIndex <= 0) return null;
  for (var index = boundaryIndex - 1; index >= 0; index--) {
    final event = events[index];
    if (event.shouldDisplayEvent) return event.eventId;
  }
  return null;
}

class _MembershipJoinViewState extends State<MembershipJoinView>
    with WidgetsBindingObserver {
  Timeline? timeline;
  final listKey = GlobalKey<AnimatedListState>();
  final scrollController = ScrollController();
  final eventUpdateStreamController = StreamController<Event>.broadcast();
  final pollUpdateStreamController = StreamController<String>.broadcast();
  final fullyReadMarkerKey = GlobalKey();
  final eventHighlightStreamController = StreamController<String>.broadcast();
  final Map<String, GlobalKey> _eventKeys = {};
  bool _hasJumpedToUnread = false;
  int _initialUnreadJumpAttempts = 0;
  bool _markingRead = false;
  bool _userScrollInProgress = false;
  bool _showLatestMessagesShortcut = false;
  String _receiptFingerprint = '';
  StreamSubscription<String>? _roomUpdateSubscription;
  StreamSubscription<SyncUpdate>? _syncSubscription;
  String? _unreadBoundaryEventId;
  String? _firstUnreadEventId;
  String? _focusedEventId;
  Set<String> _initialHistoryRevealEventIds = const {};

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    scrollController.addListener(_updateLatestMessagesShortcut);
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
    pollUpdateStreamController.close();
    eventHighlightStreamController.close();
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
    final room = RoomScope.of(context).room;
    if (timeline == null || timeline.events.isEmpty) {
      return _CachedLastEvent(room: room);
    }
    final showTyping = room.summary.mJoinedMemberCount == 3 &&
        room.typingUsers.any((user) => user.id != room.client.userID);

    return ComposeScopeWidget(
      onMessageSubmitted: _scrollToLatestAfterSend,
      child: EventNavigationScope(
        navigate: _navigateToEvent,
        highlightEvents: eventHighlightStreamController.stream,
        child: PollUpdateScope(
          eventIds: pollUpdateStreamController.stream,
          child: TimelineScope(
            timeline: timeline,
            eventChangeStream: eventUpdateStreamController.stream,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_focusedEventId != null || _showLatestMessagesShortcut)
                  Material(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.arrow_downward),
                      title: const Text('Back to latest messages'),
                      onTap: _returnToLatest,
                    ),
                  ),
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
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
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

    Widget tile = _EventHighlight(
      key: _eventKeys.putIfAbsent(event.eventId, () => GlobalKey()),
      eventId: event.eventId,
      events: eventHighlightStreamController.stream,
      child: EventScope(
        key: ValueKey(event.eventId),
        event: event,
        child: const TimelineEventTile(),
      ),
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

    if (_initialHistoryRevealEventIds.contains(event.eventId)) {
      tile = _InitialHistoryReveal(
        key: ValueKey('initial-history:${event.eventId}'),
        order: index,
        child: tile,
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
    _receiptFingerprint = _makeReceiptFingerprint(room);
    _roomUpdateSubscription ??= room.onUpdate.stream.listen((_) {
      _refreshReceipts(room);
    });
    _syncSubscription ??= room.client.onSync.stream.listen((_) {
      // Read receipts are ephemeral events: they update the room receipt
      // state without changing a timeline event, so the normal timeline
      // callbacks do not rebuild message read indicators.
      _refreshReceipts(room);
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
    await _loadHistoryThroughReadMarker(timeline, initialReadEventId);
    if (!mounted) {
      return;
    }
    _unreadBoundaryEventId = resolveUnreadBoundaryEventId(
      timeline.events,
      initialReadEventId,
      room.client.userID,
    );
    _firstUnreadEventId = firstUnreadDisplayEventId(
      timeline.events,
      _unreadBoundaryEventId,
    );
    _initialHistoryRevealEventIds = timeline.events
        .skip(1)
        .where((event) => event.shouldDisplayEvent)
        .take(12)
        .map((event) => event.eventId)
        .toSet();
    setState(() {
      this.timeline = timeline;
    });
    if (_focusedEventId == null) {
      unawaited(_markLatestRead(preserveUnreadMarker: true));
    } else {
      final focusedIndex = timeline.events.indexWhere(
        (event) => event.eventId == _focusedEventId,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !scrollController.hasClients) return;
        final focusedKey = _eventKeys[_focusedEventId];
        if (focusedKey?.currentContext == null && focusedIndex > 0) {
          scrollController.jumpTo(
            (focusedIndex * 72.0)
                .clamp(0, scrollController.position.maxScrollExtent)
                .toDouble(),
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final target = _eventKeys[_focusedEventId]?.currentContext;
          if (!mounted || target == null) return;
          Scrollable.ensureVisible(
            target,
            duration: const Duration(milliseconds: 250),
            alignment: .4,
          );
          eventHighlightStreamController.add(_focusedEventId!);
        });
      });
    }

    if (!_hasJumpedToUnread) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _jumpToInitialUnread(),
      );
    }
  }

  Future<void> _loadHistoryThroughReadMarker(
    Timeline timeline,
    String? initialReadEventId,
  ) async {
    if (initialReadEventId == null) return;
    while (timeline.events.every(
          (event) => event.eventId != initialReadEventId,
        ) &&
        timeline.canRequestHistory) {
      final previousLength = timeline.events.length;
      try {
        await timeline.requestHistory(historyCount: 50);
      } catch (error, stackTrace) {
        Logs().w(
          'Unable to load history through the unread marker.',
          error,
          stackTrace,
        );
        return;
      }
      if (timeline.events.length <= previousLength) return;
    }
  }

  Future<void> _jumpToInitialUnread() async {
    final timeline = this.timeline;
    final boundaryEventId = _unreadBoundaryEventId;
    if (!mounted ||
        timeline == null ||
        boundaryEventId == null ||
        _hasJumpedToUnread) {
      return;
    }
    final boundaryIndex = timeline.events.indexWhere(
      (event) => event.eventId == boundaryEventId,
    );
    if (boundaryIndex < 0) return;

    _hasJumpedToUnread = true;
    _initialUnreadJumpAttempts++;
    await _materializeLoadedEvent(boundaryEventId, boundaryIndex);
    if (!mounted) return;
    await WidgetsBinding.instance.endOfFrame;
    final markerContext = fullyReadMarkerKey.currentContext;
    if (markerContext == null) {
      _hasJumpedToUnread = false;
      if (_initialUnreadJumpAttempts < 4) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _jumpToInitialUnread(),
        );
      }
      return;
    }
    await Scrollable.ensureVisible(
      markerContext,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: initialUnreadMarkerAlignment,
    );
    if (!mounted) return;
    await WidgetsBinding.instance.endOfFrame;
    final firstUnreadEventId = _firstUnreadEventId;
    if (firstUnreadEventId != null) {
      eventHighlightStreamController.add(firstUnreadEventId);
    }
  }

  void _dismissUnreadMarker() {
    if (_unreadBoundaryEventId == null) return;
    setState(() {
      _unreadBoundaryEventId = null;
      _firstUnreadEventId = null;
    });
  }

  void _updateLatestMessagesShortcut() {
    if (!mounted || !scrollController.hasClients) return;
    final position = scrollController.position;
    final show = shouldShowLatestMessagesShortcut(
      pixels: position.pixels,
      viewportDimension: position.viewportDimension,
    );
    if (show == _showLatestMessagesShortcut) return;
    setState(() => _showLatestMessagesShortcut = show);
  }

  void _scrollToLatestAfterSend() {
    if (_focusedEventId != null) {
      _returnToLatest();
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;
      unawaited(
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
        ),
      );
    });
  }

  Future<void> _markLatestRead({bool preserveUnreadMarker = false}) async {
    final timeline = this.timeline;
    if (_markingRead || timeline == null || timeline.events.isEmpty) return;
    final room = RoomScope.of(context).room;
    final latestEventId = timeline.events.first.eventId;
    if (room.fullyRead == latestEventId && !room.isUnread) return;
    _markingRead = true;
    if (!preserveUnreadMarker) {
      _unreadBoundaryEventId = null;
      _firstUnreadEventId = null;
    }
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
    if (insertedEvent?.isPollResponse ?? false) {
      final target = insertedEvent?.pollResponseTarget;
      if (target != null) pollUpdateStreamController.add(target);
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

  String _makeReceiptFingerprint(Room room) {
    final entries = room.receiptState.global.otherUsers.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries
        .map((entry) => '${entry.key}:${entry.value.eventId}:${entry.value.ts}')
        .join('|');
  }

  void _refreshReceipts(Room room) {
    final fingerprint = _makeReceiptFingerprint(room);
    if (!mounted || fingerprint == _receiptFingerprint) return;
    _receiptFingerprint = fingerprint;
    final timeline = this.timeline;
    if (timeline == null) return;
    for (final event in timeline.events) {
      if (event.senderId == room.client.userID) {
        eventUpdateStreamController.add(event);
      }
    }
  }

  Future<void> _navigateToEvent(String eventId) async {
    final timeline = this.timeline;
    final index = timeline?.events.indexWhere(
          (event) => event.eventId == eventId,
        ) ??
        -1;
    if (index != -1) {
      final target = await _materializeLoadedEvent(eventId, index);
      if (target != null) {
        await Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 280),
          alignment: .4,
        );
        if (mounted) eventHighlightStreamController.add(eventId);
      }
      return;
    }

    if (!mounted) return;
    final room = RoomScope.of(context).room;
    context.goMultiClient(
      '${RoomPage.makeRouteName(room.id)}#${Uri.encodeComponent(eventId)}',
    );
  }

  Future<BuildContext?> _materializeLoadedEvent(
    String eventId,
    int eventIndex,
  ) async {
    var target = _eventKeys[eventId]?.currentContext;
    if (target != null) return target;
    final timeline = this.timeline;
    if (!mounted || timeline == null || !scrollController.hasClients) {
      return null;
    }

    final position = scrollController.position;
    final estimatedOffset = estimateReversedTimelineOffset(
      eventIndex: eventIndex,
      eventCount: timeline.events.length,
      maxScrollExtent: position.maxScrollExtent,
    );
    await scrollController.animateTo(
      estimatedOffset,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return null;
    target = _eventKeys[eventId]?.currentContext;

    // Event heights vary, so the proportional estimate can land outside the
    // cache extent. Walk by viewports toward the target until its lazy tile is
    // built, without replacing the timeline or changing the room route.
    for (var attempt = 0; target == null && attempt < 12; attempt++) {
      if (!scrollController.hasClients) return null;
      final mountedIndices = <int>[];
      for (var index = 0; index < timeline.events.length; index++) {
        if (_eventKeys[timeline.events[index].eventId]?.currentContext !=
            null) {
          mountedIndices.add(index);
        }
      }
      if (mountedIndices.isEmpty) break;
      final first = mountedIndices.reduce(min);
      final last = mountedIndices.reduce(max);
      final direction = eventIndex < first
          ? -1.0
          : eventIndex > last
              ? 1.0
              : 0.0;
      if (direction == 0) {
        await WidgetsBinding.instance.endOfFrame;
      } else {
        final current = scrollController.position;
        final next =
            (current.pixels + direction * current.viewportDimension * .8)
                .clamp(0, current.maxScrollExtent)
                .toDouble();
        if (next == current.pixels) break;
        scrollController.jumpTo(next);
        await WidgetsBinding.instance.endOfFrame;
      }
      if (!mounted) return null;
      target = _eventKeys[eventId]?.currentContext;
    }
    return target;
  }

  void _returnToLatest() {
    final room = RoomScope.of(context).room;
    if (_focusedEventId != null) {
      context.goMultiClient(RoomPage.makeRouteName(room.id));
      return;
    }
    if (!scrollController.hasClients) return;
    unawaited(
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      ),
    );
  }
}

class _CachedLastEvent extends StatelessWidget {
  const _CachedLastEvent({required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    final event = room.lastEvent;
    if (event == null || !event.shouldDisplayEvent) {
      return const Center(child: AsciiProgressIndicator());
    }
    final ownMessage = event.senderId == room.client.userID;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 16, 40, 28),
        child: Align(
          alignment: ownMessage ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                child: EventScope(
                  event: event,
                  child: const PlainEventPreviewText(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InitialHistoryReveal extends StatefulWidget {
  const _InitialHistoryReveal({
    super.key,
    required this.order,
    required this.child,
  });

  final int order;
  final Widget child;

  @override
  State<_InitialHistoryReveal> createState() => _InitialHistoryRevealState();
}

class _InitialHistoryRevealState extends State<_InitialHistoryReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: initialHistoryRevealDuration,
    );
    _startTimer =
        Timer(initialHistoryRevealDelay(widget.order), _controller.forward);
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _controller,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -.002),
            end: Offset.zero,
          ).animate(_controller),
          child: widget.child,
        ),
      );
}

class _EventHighlight extends StatefulWidget {
  const _EventHighlight({
    super.key,
    required this.eventId,
    required this.events,
    required this.child,
  });

  final String eventId;
  final Stream<String> events;
  final Widget child;

  @override
  State<_EventHighlight> createState() => _EventHighlightState();
}

class _EventHighlightState extends State<_EventHighlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;
  StreamSubscription<String>? _subscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _glow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _listen();
  }

  @override
  void didUpdateWidget(covariant _EventHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.events != widget.events ||
        oldWidget.eventId != widget.eventId) {
      _listen();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _listen() {
    _subscription?.cancel();
    _subscription = widget.events
        .where((eventId) => eventId == widget.eventId)
        .listen((_) => _controller.forward(from: 0));
  }

  @override
  Widget build(BuildContext context) {
    final neon = Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _glow,
      child: widget.child,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: neon.withValues(alpha: _glow.value * .8)),
          boxShadow: [
            BoxShadow(
              color: neon.withValues(alpha: _glow.value * .35),
              blurRadius: 10 * _glow.value,
              spreadRadius: 1.5 * _glow.value,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
