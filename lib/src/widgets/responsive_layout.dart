import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

import 'placeholder.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.uri,
    required this.main,
    required this.secondary,
    this.placeholder = const PolyculePlaceholder(),
    this.animateCompactSecondary = false,
  });

  final Uri? uri;

  final Widget main;

  final Widget? secondary;

  final Widget placeholder;

  /// Animates only the compact main/detail switch. Wide layouts remain a
  /// stable two-pane row and nested detail changes never replay the animation.
  final bool animateCompactSecondary;

  @override
  Widget build(BuildContext context) {
    final secondary = this.secondary;
    final segments =
        uri?.path.replaceFirst(RegExp(r'/client/\d+'), '').split('/');
    var showSecondary = false;
    if (segments != null) {
      segments.removeWhere((element) => element.isEmpty);
      showSecondary = segments.length >= 2 && secondary != null;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < Breakpoints.mediumLargeAndUp.beginWidth!) {
          if (animateCompactSecondary && secondary != null) {
            return CompactDetailTransition(
              showDetail: showSecondary,
              main: main,
              detail: secondary,
            );
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              main,
              if (secondary != null)
                Positioned.fill(
                  child: Offstage(
                    offstage: !showSecondary,
                    child: TickerMode(
                      enabled: showSecondary,
                      child: secondary,
                    ),
                  ),
                ),
            ],
          );
        } else {
          return Row(
            children: [
              SizedBox(
                width: 512,
                child: main,
              ),
              Expanded(child: secondary ?? placeholder),
            ],
          );
        }
      },
    );
  }
}

/// A fast, spring-driven compact navigation transition.
///
/// Both children keep stable identity. [RepaintBoundary] lets Flutter move the
/// already-painted room list and timeline as compositor layers instead of
/// rebuilding them on every animation frame.
class CompactDetailTransition extends StatefulWidget {
  const CompactDetailTransition({
    super.key,
    required this.showDetail,
    required this.main,
    required this.detail,
  });

  static const mainLayerKey = Key('compact-main-transition');
  static const detailLayerKey = Key('compact-detail-transition');

  final bool showDetail;
  final Widget main;
  final Widget detail;

  @override
  State<CompactDetailTransition> createState() =>
      _CompactDetailTransitionState();
}

class _CompactDetailTransitionState extends State<CompactDetailTransition>
    with SingleTickerProviderStateMixin {
  static final _spring = SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 180),
  );

  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: widget.showDetail ? 1 : 0,
  )..addStatusListener(_handleStatusChanged);

  @override
  void didUpdateWidget(CompactDetailTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showDetail != oldWidget.showDetail) {
      _animateTo(widget.showDetail ? 1 : 0);
    }
  }

  void _animateTo(double target) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = target;
      return;
    }
    _controller.animateWith(
      SpringSimulation(
        _spring,
        _controller.value,
        target,
        0,
        snapToEnd: true,
      ),
    );
  }

  void _handleStatusChanged(AnimationStatus status) {
    if ((status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) &&
        mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleStatusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final direction =
        Directionality.of(context) == TextDirection.rtl ? -1.0 : 1.0;
    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = _controller.value.clamp(0.0, 1.0).toDouble();
          final detailActive = widget.showDetail || _controller.isAnimating;
          return Stack(
            fit: StackFit.expand,
            children: [
              FractionalTranslation(
                key: CompactDetailTransition.mainLayerKey,
                translation: Offset(-direction * progress * .1, 0),
                child: RepaintBoundary(child: widget.main),
              ),
              Offstage(
                offstage: !detailActive,
                child: TickerMode(
                  enabled: detailActive,
                  child: IgnorePointer(
                    ignoring: !widget.showDetail,
                    child: FractionalTranslation(
                      key: CompactDetailTransition.detailLayerKey,
                      translation: Offset(direction * (1 - progress), 0),
                      child: RepaintBoundary(child: widget.detail),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
