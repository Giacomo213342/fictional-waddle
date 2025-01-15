import 'package:flutter/material.dart';

import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:matrix/matrix.dart';

import '../../../../../theme/fonts.dart';
import '../../../../../utils/matrix/autoplay_animated_content_extension.dart';
import '../../../../../utils/matrix/matrix_state.dart';
import '../../../../../utils/polycule_confetti_particle.dart';
import '../../../../../widgets/matrix/html/components/animated_emoji_extension.dart';

class CuteEventMessage extends StatefulWidget {
  const CuteEventMessage({super.key, required this.event});

  final Event event;

  @override
  State<CuteEventMessage> createState() => _CuteEventMessageState();
}

class _CuteEventMessageState extends MatrixState<CuteEventMessage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initParticles());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = (DefaultTextStyle.of(context).style.fontSize ?? 12) * 4;
    return DefaultTextStyle(
      style: TextStyle(fontSize: fontSize),
      child: GestureDetector(
        onDoubleTap: _launchConfetti,
        child: Text.rich(
          AnimatedEmojiExtension.emojifyTextSpan(widget.event.body),
        ),
      ),
    );
  }

  void _initParticles() {
    if (client.autoplayAnimatedContent ?? true) {
      _launchConfetti();
    }
  }

  void _launchConfetti() {
    const options = ConfettiOptions(
      angle: 270,
      spread: 120,
      gravity: 2,
      decay: .7,
      startVelocity: 45,
      scalar: 2,
      particleCount: 5,
      y: 0,
    );
    for (double x = .025; x < 1; x += .025) {
      Confetti.launch(
        context,
        options: options.copyWith(
          x: x,
        ),
        particleBuilder:
            widget.event.text == '\u{1F389}' ? null : _particleBuilder,
      );
    }
  }

  ConfettiParticle _particleBuilder(int index) => PolyculeConfettiParticle(
        emoji: widget.event.text,
        textStyle: TextStyle(
          fontFamily: PolyculeFonts.notoColorEmoji.name,
          fontSize: 32,
        ),
      );
}
