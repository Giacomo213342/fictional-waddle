import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ChessGridWidget extends SingleChildRenderObjectWidget {
  const ChessGridWidget({
    super.key,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    final renderObject = ChessGridPaint(
      foreground: Theme.of(context).colorScheme.secondary.withAlpha(128),
      background: Theme.of(context).colorScheme.primary.withAlpha(128),
    );
    return renderObject;
  }

  @override
  void updateRenderObject(BuildContext context, ChessGridPaint renderObject) {
    renderObject.foreground =
        Theme.of(context).colorScheme.secondary.withAlpha(128);
    renderObject.background =
        Theme.of(context).colorScheme.primary.withAlpha(128);
  }
}

class ChessGridPaint extends RenderProxyBox {
  ChessGridPaint({
    required this.foreground,
    required this.background,
    this.dimension = 12.0,
  });

  Color foreground;
  Color background;
  double dimension;

  @override
  void paint(PaintingContext context, Offset offset) {
    final background = Paint()..color = this.background;
    final foreground = Paint()..color = this.foreground;

    context.canvas.clipRect(offset & size, clipOp: ClipOp.intersect);
    context.canvas.drawRect(offset & size, background);

    final dx = size.width % dimension / 2 - dimension;
    final dy = size.height % dimension / 2 - dimension;
    for (double x = dx; x < size.width; x += dimension) {
      for (double y = (x - dx) / dimension % 2 == 0 ? dy : dimension + dy;
          y < size.height;
          y += dimension * 2) {
        context.canvas.drawRect(
          offset + Offset(x, y) & Size.square(dimension),
          foreground,
        );
      }
    }

    final child = this.child;
    if (child != null) {
      context.paintChild(child, offset);
    }
  }
}
