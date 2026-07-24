import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Adds an interactive Android predictive-back transition to declarative
/// destinations that cannot be popped and must navigate to an explicit URI.
///
/// Normal Navigator pages use Flutter's [PredictiveBackPageTransitionsBuilder].
/// This scope is only for roots whose back operation is implemented with
/// `go()`, where [PopScope.canPop] must remain false.
class AndroidPredictiveBackScope extends StatefulWidget {
  const AndroidPredictiveBackScope({
    super.key,
    required this.onBack,
    required this.child,
  });

  final VoidCallback onBack;
  final Widget child;

  @override
  State<AndroidPredictiveBackScope> createState() =>
      _AndroidPredictiveBackScopeState();
}

class _AndroidPredictiveBackScopeState extends State<AndroidPredictiveBackScope>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );
  SwipeEdge _swipeEdge = SwipeEdge.left;
  bool _canHandleGesture = false;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _progress.dispose();
    super.dispose();
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    if (!_isAndroid || !_canHandleGesture || backEvent.isButtonEvent) {
      return false;
    }
    _swipeEdge = backEvent.swipeEdge;
    _progress.value = backEvent.progress;
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    _progress.value = backEvent.progress;
  }

  @override
  void handleCancelBackGesture() {
    _progress.animateBack(
      0,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void handleCommitBackGesture() {
    widget.onBack();
    _progress.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    _canHandleGesture = TickerMode.valuesOf(context).enabled &&
        (ModalRoute.of(context)?.isCurrent ?? true);
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          widget.onBack();
        }
      },
      child: AnimatedBuilder(
        animation: _progress,
        child: widget.child,
        builder: (context, child) {
          final progress = Curves.easeOutCubic.transform(_progress.value);
          final direction = _swipeEdge == SwipeEdge.left ? 1.0 : -1.0;
          return ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: Transform.translate(
              offset: Offset(direction * 20 * progress, 0),
              child: Transform.scale(
                scale: 1 - .08 * progress,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28 * progress),
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
