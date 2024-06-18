import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../widgets/ascii_progress_indicator.dart';
import '../../room.dart';
import '../event/compose/message_input.dart';
import '../timeline.dart';

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
          child: TimelineView(
            controller: widget.controller,
            room: widget.room,
            timeline: timeline,
            listKey: listKey,
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
    listKey.currentState
        ?.removeItem(index, (context, animation) => Container());
  }

  void _changeEvent(int index) {
    listKey.currentState
        ?.removeItem(index, (context, animation) => Container());
    listKey.currentState?.insertItem(index);
  }
}
