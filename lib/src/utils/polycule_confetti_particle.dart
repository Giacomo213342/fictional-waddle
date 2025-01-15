import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'package:flutter_confetti/flutter_confetti.dart';

class PolyculeConfettiParticle extends ConfettiParticle {
  PolyculeConfettiParticle({
    required this.emoji,
    this.textStyle,
  });

  final String emoji;
  final TextStyle? textStyle;

  ui.Image? _cachedImage;

  Future<ui.Image> _createTextImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final textStyle = this.textStyle ?? const TextStyle();
    final fontSize = textStyle.fontSize ?? 18;
    final scaleFontSize = fontSize;

    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: textStyle.copyWith(fontSize: scaleFontSize),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);

    final picture = recorder.endRecording();
    final imageSize = (scaleFontSize * 1.5).toInt();

    return picture.toImage(imageSize, imageSize);
  }

  @override
  void paint({
    required ConfettiPhysics physics,
    required Canvas canvas,
  }) {
    final image = _cachedImage;
    if (image == null) {
      _createTextImage().then((image) {
        _cachedImage = image;
      });
      return;
    }

    canvas.save();

    canvas.translate(physics.x, physics.y);
    canvas.rotate(pi / 10 * physics.wobble);
    // canvas.scale(0.25, 0.25);

    final paint = Paint()
      ..color = Color.fromRGBO(255, 255, 255, 1 - physics.progress);

    canvas.drawImage(image, Offset.zero, paint);

    canvas.restore();
  }
}
