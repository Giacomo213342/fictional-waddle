import 'package:flutter/material.dart';

import 'package:emoji_extension/emoji_extension.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:matrix/matrix.dart';

import '../../../../../theme/fonts.dart';
import '../../../../../utils/matrix/autoplay_animated_content_extension.dart';
import '../../../../../utils/polycule_confetti_particle.dart';
import '../../../../../widgets/matrix/html/components/animated_emoji_extension.dart';
import '../../../../../widgets/matrix/scopes/client_scope.dart';
import '../../../../../widgets/matrix/scopes/event_scope.dart';

class CuteEventMessage extends StatefulWidget {
  const CuteEventMessage({super.key});

  @override
  State<CuteEventMessage> createState() => _CuteEventMessageState();
}

class _CuteEventMessageState extends State<CuteEventMessage> {
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
          AnimatedEmojiExtension.emojifyTextSpan(getEmote()),
        ),
      ),
    );
  }

  void _initParticles() {
    if (ClientScope.of(context).client.autoplayAnimatedContent ?? true) {
      _launchConfetti();
    }
  }

  void _launchConfetti() {
    final emote = getEmote();
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
            // confetti
            emote == '\u{1F389}'
                ? null
                :
                // rain
                emote == '\u{1f327}' || emote == '\u{1f327}\u{fe0f}'
                    ? _rainBuilder
                    : _particleBuilder,
      );
    }
  }

  ConfettiParticle _rainBuilder(int index) => PolyculeConfettiParticle(
        // water drop
        emoji: '\u{1f4a7}',
        textStyle: TextStyle(
          fontFamily: PolyculeFonts.notoColorEmoji.name,
          fontSize: 32,
        ),
      );

  ConfettiParticle _particleBuilder(int index) => PolyculeConfettiParticle(
        emoji: getEmote(),
        textStyle: TextStyle(
          fontFamily: PolyculeFonts.notoColorEmoji.name,
          fontSize: 32,
        ),
      );

  String getEmote() {
    final event = EventScope.of(context).event;
    final emote = event.messageType == MessageTypes.Emote
        ? event.body.emojis.firstOrNull?.value ?? event.body
        : event.body;
    return emote;
  }
}
