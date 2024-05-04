import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

class TextMessage extends StatelessWidget {
  const TextMessage({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    double textScaleFactor = 1;
    if (event.onlyEmotes) {
      textScaleFactor = 4;
    }
    String prefix = '';
    if (event.messageType == MessageTypes.Emote) {
      // Unicode Bullet
      prefix = '\u2022 ';
    }
    return Text(
      prefix + event.text,
      textScaler: TextScaler.linear(textScaleFactor),
    );
  }
}
