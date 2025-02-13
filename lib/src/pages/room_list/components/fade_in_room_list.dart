import 'dart:async';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../widgets/matrix/scopes/client_scope.dart';
import 'sliding_sync_proxy.dart';

class FadeInRoomList extends StatefulWidget {
  const FadeInRoomList({super.key});

  @override
  State<FadeInRoomList> createState() => _FadeInRoomListState();
}

class _FadeInRoomListState extends State<FadeInRoomList>
    with TickerProviderStateMixin {
  AnimationController? _animation;
  StreamSubscription<SyncUpdate>? _subscription;

  @override
  Widget build(BuildContext context) {
    final animation = makeAnimation(context);

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) => Opacity(
        opacity: .5 + (animation.value - .5).abs(),
        child: child,
      ),
      child: SlidingSyncProxy(
        key: Key(ClientScope.of(context).client.clientName),
      ),
    );
  }

  @override
  void dispose() {
    _animation?.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  AnimationController makeAnimation(BuildContext context) {
    AnimationController? animation = _animation;
    if (animation != null) {
      return animation;
    }
    final client = ClientScope.of(context).client;

    _animation = animation = AnimationController(
      lowerBound: 0,
      upperBound: 1,
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    final sync = client.onSync.value;
    if (sync == null) {
      animation.repeat();
      _subscription = client.onSync.stream.listen(
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
