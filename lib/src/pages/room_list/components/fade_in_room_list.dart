import 'dart:async';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../room_list.dart';
import 'sliding_sync_proxy.dart';

class FadeInRoomList extends StatefulWidget {
  const FadeInRoomList(this.controller, {super.key});

  final RoomListController controller;

  @override
  State<FadeInRoomList> createState() => _FadeInRoomListState();
}

class _FadeInRoomListState extends State<FadeInRoomList>
    with TickerProviderStateMixin {
  AnimationController? _animation;
  StreamSubscription<SyncUpdate>? _subscription;

  @override
  Widget build(BuildContext context) {
    final animation = makeAnimation();

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) => Opacity(
        opacity: .5 + (animation.value - .5).abs(),
        child: child,
      ),
      child: SlidingSyncProxy(controller: widget.controller),
    );
  }

  @override
  void dispose() {
    _animation?.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  AnimationController makeAnimation() {
    AnimationController? animation = _animation;
    if (animation != null) {
      return animation;
    }

    _animation = animation = AnimationController(
      lowerBound: 0,
      upperBound: 1,
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    final sync = widget.controller.client.onSync.value;
    if (sync == null) {
      animation.repeat();
      _subscription = widget.controller.client.onSync.stream.listen(
        (_) => _cancelAnimation(),
      );
    }
    return animation;
  }

  Future<void> _cancelAnimation() async {
    _subscription?.cancel();
    _subscription = null;

    _animation?.stop();
    await _animation?.animateBack(0);
    _animation?.dispose();
    _animation = null;
  }
}
